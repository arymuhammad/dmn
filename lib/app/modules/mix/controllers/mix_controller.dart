import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/mix_episode_model.dart';
import '../../../data/repositories/mix_repository.dart';
import '../../../data/services/api_config.dart';

class MixController extends GetxController {
  final MixRepository repository;
  MixController(this.repository);
  // ================= // PAGE // =================
  final PageController pageController = PageController();
  final episodes = <MixEpisodeModel>[].obs;
  final currentIndex = 0.obs;
  final loading = true.obs;
  // ================= // MEDIA KIT PLAYERS // =================
  final Map<int, Player> players = {};
  final Map<int, VideoController> videoControllers = {};
  final RxSet<int> initializingPlayers = <int>{}.obs;
  final RxSet<int> readyPlayers = <int>{}.obs;
  // ================= // WAITING PLAYER INITIALIZATION // ================= // // Kalau player sedang dibuat, pemanggilan preparePlayer()
  // berikutnya akan menunggu Future yang sama. //
  final Map<int, Future<void>> preparingPlayers = {};
  // ================= // SYNOPSIS // =================
  final expandedSynopsis = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadMix();
  }

  // ================= // LOAD MIX // =================
  Future<void> loadMix() async {
    try {
      loading.value = true;
      final data = await repository.mix();
      episodes.assignAll(data);
      if (episodes.isEmpty) {
        return;
      }
      currentIndex.value = 0;
      // ============= // PREPARE PLAYER 0 // =============
      _prepareInitialPlayers();
    } catch (e) {
      debugPrint('[MIX] LOAD ERROR: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _prepareInitialPlayers() async {
    // ========================================================
    // PLAYER PERTAMA
    // ========================================================

    await preparePlayer(0, autoplay: true);

    // ========================================================
    // PRELOAD PLAYER BERIKUTNYA
    // Tunggu first frame video pertama terlebih dahulu supaya
    // preload tidak mengganggu startup video utama.
    // ========================================================

    final firstVideoController = videoControllers[0];

    if (firstVideoController != null && episodes.length > 1) {
      try {
        await firstVideoController.waitUntilFirstFrameRendered;

        debugPrint('[MIX] FIRST VIDEO READY - PRELOAD NEXT');

        // User mungkin sudah pindah halaman.
        // Tetap preload index 1 karena ini memang next video.
        preparePlayer(1, autoplay: false);
      } catch (e) {
        debugPrint(
          '[MIX] PRELOAD NEXT ERROR '
          'index=1 '
          'error=$e',
        );
      }
    }
  }

  // ================= // PREPARE PLAYER // =================
  Future<void> preparePlayer(int index, {bool autoplay = false}) async {
    if (index < 0 || index >= episodes.length) {
      return;
    }

    // ========================================================
    // SUDAH READY
    // ========================================================

    if (players.containsKey(index) && readyPlayers.contains(index)) {
      if (autoplay) {
        final player = players[index];

        if (player != null && !player.state.playing) {
          await player.play();
        }
      }

      return;
    }

    // ========================================================
    // SEDANG DIPROSES
    // ========================================================

    final pending = preparingPlayers[index];

    if (pending != null) {
      await pending;

      if (autoplay &&
          currentIndex.value == index &&
          readyPlayers.contains(index)) {
        final player = players[index];

        if (player != null && !player.state.playing) {
          await player.play();
        }
      }

      return;
    }

    // ========================================================
    // PLAYER SUDAH ADA
    // ========================================================

    if (players.containsKey(index)) {
      return;
    }

    final episode = episodes[index];

    if (episode.videoUrl.isEmpty) {
      return;
    }

    // ========================================================
    // CREATE
    // ========================================================

    final future = _createPlayer(index, autoplay: autoplay);

    preparingPlayers[index] = future;

    try {
      await future;

      // ======================================================
      // AUTOPLAY SETELAH PREPARE
      // ======================================================

      if (autoplay &&
          currentIndex.value == index &&
          readyPlayers.contains(index)) {
        final player = players[index];

        if (player != null && !player.state.playing) {
          await player.play();
        }
      }
    } finally {
      preparingPlayers.remove(index);
    }
  }

  // ================= // CREATE PLAYER // =================

  Future<void> _createPlayer(int index, {bool autoplay = false}) async {
    if (index < 0 || index >= episodes.length) {
      return;
    }

    if (initializingPlayers.contains(index)) {
      return;
    }

    final episode = episodes[index];

    if (episode.videoUrl.isEmpty) {
      return;
    }

    initializingPlayers.add(index);
    update(['video_$index']);

    try {
      // ========================================================
      // PLAYER
      // ========================================================

      final stopwatch = Stopwatch()..start();

      final player = Player();

      // ========================================================
      // POSITION DIAGNOSTIC
      // ========================================================

      bool bufferLogged = false;

      player.stream.buffer.listen((buffer) {
        if (!bufferLogged && buffer > Duration.zero) {
          bufferLogged = true;

          debugPrint(
            '[MIX] FIRST BUFFER '
            'index=$index '
            'buffer=${buffer.inMilliseconds} ms '
            'elapsed=${stopwatch.elapsedMilliseconds} ms',
          );
        }
      });

      // ========================================================
      // VIDEO CONTROLLER
      // ========================================================

      final videoController = VideoController(player);

      // ========================================================
      // PLAYING DIAGNOSTIC
      // ========================================================

      player.stream.playing.listen((playing) {
        debugPrint(
          '[MIX] PLAYING '
          'index=$index '
          'value=$playing '
          'elapsed=${stopwatch.elapsedMilliseconds} ms',
        );
      });

      // ========================================================
      // BUFFERING DIAGNOSTIC
      // ========================================================

      player.stream.buffering.listen((buffering) {
        debugPrint(
          '[MIX] BUFFERING '
          'index=$index '
          'value=$buffering '
          'elapsed=${stopwatch.elapsedMilliseconds} ms',
        );
      });

      // ========================================================
      // FIRST FRAME DIAGNOSTIC
      // ========================================================

      videoController.waitUntilFirstFrameRendered
          .then((_) {
            debugPrint(
              '[MIX] FIRST FRAME '
              'index=$index '
              'elapsed=${stopwatch.elapsedMilliseconds} ms',
            );
          })
          .catchError((error) {
            debugPrint(
              '[MIX] FIRST FRAME ERROR '
              'index=$index '
              'error=$error',
            );
          });

      // ========================================================
      // SAVE PLAYER
      // ========================================================

      players[index] = player;
      videoControllers[index] = videoController;

      update(['video_$index']);

      // ========================================================
      // URL
      // ========================================================

      final String videoPath =
          episode.isVip == 1 ? episode.previewUrl : episode.videoUrl;

      if (videoPath.isEmpty) {
        debugPrint(
          '[MIX] VIDEO URL EMPTY '
          'index=$index '
          'vip=${episode.isVip}',
        );

        return;
      }

      // final String url = videoPath;
      final String url =
          videoPath.contains('master.m3u8')
              ? videoPath.replaceFirst('master.m3u8', 'stream_1/index.m3u8')
              : videoPath;

      debugPrint(
        '[MIX] OPEN PLAYER '
        'index=$index '
        'url=$url',
      );

      // ========================================================
      // OPEN MEDIA
      // ========================================================

      debugPrint(
        '[MIX] OPEN START '
        'index=$index '
        'time=${DateTime.now()}',
      );

      await player.open(Media(url), play: false);

      debugPrint(
        '[MIX] OPEN DONE '
        'index=$index '
        'elapsed=${stopwatch.elapsedMilliseconds} ms '
        'autoplay=$autoplay',
      );

      // ========================================================
      // AUTOPLAY
      // ========================================================
      if (autoplay) {
        await player.play();

        debugPrint(
          '[MIX] AUTOPLAY REQUESTED '
          'index=$index '
          'elapsed=${stopwatch.elapsedMilliseconds} ms',
        );
      }

      // ========================================================
      // READY
      // ========================================================

      readyPlayers.add(index);

      update(['video_$index']);

      debugPrint(
        '[MIX] PLAYER READY '
        'index=$index '
        'episode=${episode.id} '
        'elapsed=${stopwatch.elapsedMilliseconds} ms',
      );

      // ========================================================
      // LOOP
      // ========================================================

      player.setPlaylistMode(PlaylistMode.single).catchError((e) {
        debugPrint(
          '[MIX] PLAYLIST MODE ERROR '
          'index=$index '
          'error=$e',
        );
      });
    } catch (e) {
      debugPrint(
        '[MIX] PLAYER ERROR '
        'index=$index '
        'error=$e',
      );

      final failedPlayer = players.remove(index);

      videoControllers.remove(index);

      readyPlayers.remove(index);

      try {
        await failedPlayer?.dispose();
      } catch (_) {}

      update(['video_$index']);
    } finally {
      initializingPlayers.remove(index);

      update(['video_$index']);
    }
  }

  VideoController? getVideoController(int index) {
    return videoControllers[index];
  } // ================= // GET PLAYER // =================

  Player? getPlayer(int index) {
    return players[index];
  } // ================= // PLAYER READY // =================

  bool isPlayerReady(int index) {
    return readyPlayers.contains(index);
  } // ================= // TOGGLE PLAY / PAUSE // =================

  Future<void> togglePlayPause(int index) async {
    if (index != currentIndex.value) {
      return;
    }
    if (!readyPlayers.contains(index)) {
      return;
    }
    final player = players[index];
    if (player == null) {
      return;
    }
    try {
      await player.playOrPause();
      debugPrint(
        '[MIX] TOGGLE PLAY/PAUSE '
        'index=$index '
        'playing=${player.state.playing}',
      );
    } catch (e) {
      debugPrint(
        '[MIX] TOGGLE ERROR '
        'index=$index '
        'error=$e',
      );
    }
  }

  // ================= // PAGE CHANGED // =================
  Future<void> onPageChanged(int index) async {
    currentIndex.value = index;
    expandedSynopsis.value = null;

    // ========================================================
    // PAUSE VIDEO LAIN
    // ========================================================

    for (final entry in players.entries) {
      if (entry.key != index) {
        try {
          await entry.value.pause();
        } catch (e) {
          debugPrint(
            '[MIX] PAUSE OTHER ERROR '
            'index=${entry.key} '
            'error=$e',
          );
        }
      }
    }

    // ========================================================
    // CURRENT VIDEO
    // ========================================================

    final currentPlayer = players[index];

    if (currentPlayer != null && readyPlayers.contains(index)) {
      try {
        await currentPlayer.seek(Duration.zero);
        await currentPlayer.play();

        debugPrint(
          '[MIX] PLAY CURRENT '
          'index=$index',
        );
      } catch (e) {
        debugPrint(
          '[MIX] PLAY CURRENT ERROR '
          'index=$index '
          'error=$e',
        );
      }
    } else {
      // ======================================================
      // BELUM READY
      // ======================================================

      await preparePlayer(index, autoplay: false);

      // Pastikan user masih di index ini
      if (currentIndex.value != index) {
        return;
      }

      final player = players[index];

      if (player != null && readyPlayers.contains(index)) {
        try {
          await player.seek(Duration.zero);
          await player.play();

          debugPrint(
            '[MIX] PLAY AFTER PREPARE '
            'index=$index',
          );
        } catch (e) {
          debugPrint(
            '[MIX] PLAY AFTER PREPARE ERROR '
            'index=$index '
            'error=$e',
          );
        }
      }
    }

    // ========================================================
    // PRELOAD NEXT
    // ========================================================

    if (index + 1 < episodes.length) {
      preparePlayer(index + 1, autoplay: false);
    }

    // ========================================================
    // PRELOAD PREVIOUS
    // ========================================================

    if (index - 1 >= 0) {
      preparePlayer(index - 1, autoplay: false);
    }

    // ========================================================
    // CLEANUP
    // ========================================================

    cleanupPlayers(index);
  } // ================= // PAUSE ALL VIDEO // =================

  Future<void> pauseAllVideos() async {
    for (final player in players.values) {
      try {
        await player.pause();
      } catch (e) {
        debugPrint('[MIX] PAUSE ERROR: $e');
      }
    }
    debugPrint('[MIX] ALL VIDEOS PAUSED');
  } // ================= // RESUME VIDEO // =================

  Future<void> resumeCurrentVideo() async {
    final index = currentIndex.value;
    if (index < 0 || index >= episodes.length) {
      return;
    } // Player belum ada → prepare
    if (!players.containsKey(index)) {
      await preparePlayer(index);
    } // Kalau masih belum ready → tunggu prepare
    if (!readyPlayers.contains(index)) {
      await preparePlayer(index);
    }
    final player = players[index];
    if (player == null) {
      debugPrint(
        '[MIX] RESUME FAILED - PLAYER NULL '
        'index=$index',
      );
      return;
    }
    try {
      await player.play();
      debugPrint(
        '[MIX] RESUME VIDEO '
        'index=$index '
        'episode=${episodes[index].id}',
      );
    } catch (e) {
      debugPrint(
        '[MIX] RESUME ERROR '
        'index=$index '
        'error=$e',
      );
    }
  } // ================= // CLEANUP PLAYER // =================

  Future<void> cleanupPlayers(int current) async {
    final indexes = players.keys.toList();
    for (final index in indexes) {
      if ((index - current).abs() > 1) {
        final player = players.remove(index);
        videoControllers.remove(index);
        readyPlayers.remove(index);
        preparingPlayers.remove(index);
        try {
          await player?.dispose();
        } catch (_) {}
        debugPrint('[MIX] DISPOSE PLAYER index=$index');
      }
    }
  } // ================= // SYNOPSIS // =================

  void toggleSynopsis(int episodeId) {
    if (expandedSynopsis.value == episodeId) {
      expandedSynopsis.value = null;
    } else {
      expandedSynopsis.value = episodeId;
    }
  }

  bool isSynopsisExpanded(int episodeId) {
    return expandedSynopsis.value == episodeId;
  } // ================= // CLOSE // =================

  @override
  void onClose() {
    pageController.dispose();
    for (final player in players.values) {
      player.dispose();
    }
    players.clear();
    videoControllers.clear();
    preparingPlayers.clear();
    readyPlayers.clear();
    initializingPlayers.clear();
    super.onClose();
  }
}
