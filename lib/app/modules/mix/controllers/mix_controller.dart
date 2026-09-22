import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/mix_episode_model.dart';
import '../../../data/repositories/mix_repository.dart';
import '../../../data/services/api_config.dart';

class MixController extends GetxController {
  final MixRepository repository;

  MixController(this.repository);

  // ==========================================================
  // PAGE
  // ==========================================================

  final PageController pageController = PageController();

  final episodes = <MixEpisodeModel>[].obs;

  final currentIndex = 0.obs;

  final loading = true.obs;

  // ==========================================================
  // MEDIA KIT PLAYERS
  // ==========================================================

  final Map<int, Player> players = {};

  final Map<int, VideoController> videoControllers = {};

  final RxSet<int> initializingPlayers = <int>{}.obs;

  final RxSet<int> readyPlayers = <int>{}.obs;

  // ==========================================================
  // SYNOPSIS
  // ==========================================================

  final expandedSynopsis = Rxn<int>();

  @override
  void onInit() {
    super.onInit();

    loadMix();
  }

  // ==========================================================
  // LOAD MIX
  // ==========================================================

  Future<void> loadMix() async {
    try {
      loading.value = true;

      final data = await repository.mix();

      episodes.assignAll(data);

      if (episodes.isEmpty) {
        return;
      }

      currentIndex.value = 0;

      // ======================================================
      // PREPARE PLAYER 0 DI BACKGROUND
      // ======================================================

      _prepareInitialPlayers();
    } catch (e) {
      debugPrint('[MIX] LOAD ERROR: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _prepareInitialPlayers() async {
    // Player pertama
    await preparePlayer(0);

    // Jangan autoplay di sini kalau Mix belum aktif.
    //
    // Player hanya dipersiapkan.
    //
    // Ketika user masuk Mix, resumeCurrentVideo()
    // yang akan menjalankan play().
  }

  // ==========================================================
  // PREPARE PLAYER
  // ==========================================================

  Future<void> preparePlayer(int index) async {
    if (index < 0 || index >= episodes.length) {
      return;
    }

    if (players.containsKey(index)) {
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

    try {
      // ========================================================
      // PLAYER
      // ========================================================

      final player = Player();

      // ========================================================
      // VIDEO CONTROLLER
      // ========================================================

      final videoController = VideoController(player);

      players[index] = player;

      videoControllers[index] = videoController;

      // ========================================================
      // OPEN MEDIA
      // ========================================================
      String url = ApiConfig.baseUrl + episode.videoUrl;
      await player.open(Media(url), play: false);

      // ========================================================
      // LOOP
      // ========================================================

      await player.setPlaylistMode(PlaylistMode.single);

      // ========================================================
      // READY
      // ========================================================

      readyPlayers.add(index);
      update(['video_$index']);

      debugPrint(
        '[MIX] PLAYER READY '
        'index=$index '
        'episode=${episode.id}',
      );
    } catch (e) {
      debugPrint(
        '[MIX] PLAYER ERROR '
        'index=$index '
        'error=$e',
      );

      final player = players.remove(index);

      videoControllers.remove(index);

      readyPlayers.remove(index);

      await player?.dispose();
      update(['video_$index']);
    } finally {
      initializingPlayers.remove(index);
    }
  }

  VideoController? getVideoController(int index) {
    return videoControllers[index];
  }

  // ==========================================================
  // PAGE CHANGED
  // ==========================================================

  Future<void> onPageChanged(int index) async {
    currentIndex.value = index;

    expandedSynopsis.value = null;

    // ========================================================
    // PAUSE VIDEO LAIN
    // ========================================================

    for (final entry in players.entries) {
      if (entry.key != index) {
        await entry.value.pause();
      }
    }

    // ========================================================
    // CURRENT VIDEO
    // ========================================================

    final currentPlayer = players[index];

    if (currentPlayer != null && readyPlayers.contains(index)) {
      await currentPlayer.seek(Duration.zero);
      await currentPlayer.play();
    } else {
      // Kalau belum ready, prepare di background
      preparePlayer(index).then((_) async {
        // Pastikan user masih berada di index ini
        if (currentIndex.value != index) {
          return;
        }

        final player = players[index];

        if (player != null && readyPlayers.contains(index)) {
          await player.seek(Duration.zero);
          await player.play();
        }
      });
    }

    // ========================================================
    // PRELOAD NEXT
    // ========================================================

    preparePlayer(index + 1);

    // ========================================================
    // PRELOAD PREVIOUS
    // ========================================================

    preparePlayer(index - 1);

    // ========================================================
    // CLEANUP
    // ========================================================

    cleanupPlayers(index);
  }

  // ========================================================
  // PAUSE ALL VIDEO
  // ========================================================

  Future<void> pauseAllVideos() async {
    for (final player in players.values) {
      try {
        await player.pause();
      } catch (e) {
        debugPrint('[MIX] PAUSE ERROR: $e');
      }
    }

    debugPrint('[MIX] ALL VIDEOS PAUSED');
  }

  // ========================================================
  // RESUME VIDEO
  // ========================================================

  Future<void> resumeCurrentVideo() async {
    final index = currentIndex.value;

    if (index < 0 || index >= episodes.length) {
      return;
    }

    // Player belum ada → prepare
    if (!players.containsKey(index)) {
      await preparePlayer(index);
    }

    final player = players[index];

    if (player == null) {
      debugPrint('[MIX] RESUME FAILED - PLAYER NULL index=$index');
      return;
    }

    try {
      await player.play();

      debugPrint(
        '[MIX] RESUME VIDEO index=$index '
        'episode=${episodes[index].id}',
      );
    } catch (e) {
      debugPrint(
        '[MIX] RESUME ERROR '
        'index=$index '
        'error=$e',
      );
    }
  }

  // ==========================================================
  // CLEANUP PLAYER
  // ==========================================================

  Future<void> cleanupPlayers(int current) async {
    final indexes = players.keys.toList();

    for (final index in indexes) {
      if ((index - current).abs() > 1) {
        final player = players.remove(index);

        videoControllers.remove(index);

        readyPlayers.remove(index);

        await player?.dispose();

        debugPrint('[MIX] DISPOSE PLAYER index=$index');
      }
    }
  }

  // ==========================================================
  // GET PLAYER
  // ==========================================================

  Player? getPlayer(int index) {
    return players[index];
  }

  bool isPlayerReady(int index) {
    return readyPlayers.contains(index);
  }

  // ==========================================================
  // SYNOPSIS
  // ==========================================================

  void toggleSynopsis(int episodeId) {
    if (expandedSynopsis.value == episodeId) {
      expandedSynopsis.value = null;
    } else {
      expandedSynopsis.value = episodeId;
    }
  }

  bool isSynopsisExpanded(int episodeId) {
    return expandedSynopsis.value == episodeId;
  }

  // ==========================================================
  // CLOSE
  // ==========================================================

  @override
  void onClose() {
    pageController.dispose();

    for (final player in players.values) {
      player.dispose();
    }

    players.clear();

    super.onClose();
  }
}
