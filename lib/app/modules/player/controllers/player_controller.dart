import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmn_play/app/data/models/movie_model.dart';
import 'package:dmn_play/app/data/models/watch_history_model.dart';
import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:volume_controller/volume_controller.dart';

import '../../../data/helpers/format_duration.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/episode_subtitle.dart';
import '../../../data/models/quality_model.dart';
import '../../../data/models/subtitle_cue.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/services/api_config.dart';
import '../../history/controllers/history_controller.dart';
import '../../account/views/widget/vip_upgrade_view.dart';
import '../views/widgets/dialogs/episode_dialog.dart';
import '../views/widgets/dialogs/quality_dialog.dart';
import '../views/widgets/dialogs/speed_dialog.dart';
import '../views/widgets/dialogs/subtitle_dialog.dart';

enum DragType { none, horizontal, brightness, volume }

class PlayerController extends GetxController {
  VideoController? videoController;
  Player? player;

  final List<StreamSubscription<dynamic>> _playerSubscriptions = [];
  bool _fromMix = false;
  bool _ownsPlayer = true;

  // final String hlsPath = Get.arguments as String;
  String url = "";
  late final HistoryRepository historyRepository;
  late EpisodeModel episode;

  final isPlaying = false.obs;
  final isBuffering = true.obs;
  final isCompleted = false.obs;
  final isFullscreen = false.obs;
  final isLocked = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final buffer = Duration.zero.obs;
  final playbackSpeed = 1.0.obs;

  final currentEpisodeId = 0.obs;

  late final PageController pageController;
  final currentEpisodeIndex = 0.obs;

  // final isSeeking = false.obs;
  // final seekPosition = Duration.zero.obs;
  RxList<QualityModel> qualities = <QualityModel>[].obs;
  RxString selectedQuality = 'Auto'.obs;

  final synopsis = ''.obs;
  RxList<String> cast = <String>[].obs;

  final subtitles = <EpisodeSubtitle>[].obs;
  final currentSubtitle = Rxn<EpisodeSubtitle>();
  Map<String, String> subtitleCache = {};
  // final hasNextEpisode = false.obs;
  // final countdown = 10.obs;
  // final introStart = Duration.zero.obs;
  // final introEnd = Duration.zero.obs;

  final volume = 100.0.obs;
  final showVolume = false.obs;
  final brightness = 1.0.obs;
  final showBrightness = false.obs;

  // final audioTracks = <String>[].obs;
  // final selectedAudio = "".obs;
  // final casting = false.obs;
  final controlsVisible = true.obs;
  Timer? _overlayTimer;
  final showForwardAnimation = false.obs;
  final showBackwardAnimation = false.obs;

  final forwardSeconds = 0.obs;
  final backwardSeconds = 0.obs;

  Timer? _volumeTimer;
  Timer? _brightnessTimer;

  final isScrubbing = false.obs;
  final scrubPosition = Duration.zero.obs;
  final title = "".obs;
  final poster = "".obs;

  final episodes = <EpisodeModel>[].obs;

  RxList<VideoTrack> videoTracks = <VideoTrack>[].obs;

  Timer? _historyTimer;
  int _lastSyncedSecond = 0;

  bool viewCounted = false;
  RxBool expanded = false.obs;

  Offset? start;

  DragType dragType = DragType.none;

  bool isLeftSide = false;

  TapDownDetails? doubleTapPosition;

  final showSeek = false.obs;
  final seekDelta = 0.obs;

  final cues = <SubtitleCue>[].obs;

  final currentSubtitleText = "".obs;
  int currentIndex = 0;

  int resumeSeconds = 0;

  bool _changingEpisode = false;

  // static const MethodChannel _pipChannel = MethodChannel('pip');

  @override
  void onInit() {
    super.onInit();

    pageController = PageController();

    _initialize();
  }

  @override
  void onClose() {
    _historyTimer?.cancel();

    // Hentikan semua listener Player milik controller ini.
    // Penting terutama untuk MIX karena Player-nya tidak di-dispose.
    for (final subscription in _playerSubscriptions) {
      unawaited(subscription.cancel());
    }
    _playerSubscriptions.clear();

    // Simpan history terakhir
    unawaited(saveHistoryIfLoggedIn());

    _overlayTimer?.cancel();

    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();

    pageController.dispose();

    // Player normal tetap di-dispose.
    // Player MIX tidak disentuh karena masih dipakai oleh Mix.
    if (_ownsPlayer) {
      player?.dispose();
    }

    super.onClose();
  }

  // Future<void> _updateNativePlayingState(bool playing) async {
  //   try {
  //     await _pipChannel.invokeMethod('set_playing', {'playing': playing});
  //   } catch (_) {}
  // }

  Future<void> _initialize() async {
    unawaited(cleanOldSubtitleCache());

    final args = Get.arguments as Map;

    historyRepository = Get.find<HistoryRepository>();

    // ==========================================================
    // MODE DARI MIX
    // ==========================================================

    // ==========================================================
    // MODE DARI MIX
    // ==========================================================

    if (args['fromMix'] == true &&
        args['player'] is Player &&
        args['videoController'] is VideoController) {
      _fromMix = true;
      _ownsPlayer = false;

      // ========================================================
      // REUSE PLAYER
      // ========================================================

      player = args['player'] as Player;

      videoController = args['videoController'] as VideoController;

      // ========================================================
      // DATA
      // ========================================================

      currentEpisodeId.value =
          int.tryParse(args['episodeId']?.toString() ?? '') ?? 0;

      title.value = args['title']?.toString() ?? '';
      poster.value = args['poster']?.toString() ?? '';
      synopsis.value = args['synopsis']?.toString() ?? '';
      cast.assignAll(args['cast']);
      // ========================================================
      // SUBTITLE
      // ========================================================

      final mixSubtitles = args['subtitles'];

      if (mixSubtitles is List<EpisodeSubtitle>) {
        subtitles.assignAll(mixSubtitles);
      } else {
        subtitles.clear();
      }

      // ========================================================
      // QUALITY
      // ========================================================

      final mixQualities = args['qualities'];

      if (mixQualities is List<QualityModel>) {
        qualities.assignAll(mixQualities);
      } else {
        qualities.clear();
      }

      // ========================================================
      // BENTUK EPISODE UNTUK HISTORY
      // ========================================================

      episode = EpisodeModel(
        id: currentEpisodeId.value,
        movieId: args['movieId'] ?? 0,
        title: args['title'] ?? '',
        videoUrl: args['videoUrl'] ?? '',
        episodeNumber: args['episodeNumber'] ?? 0,
        duration: args['duration'] ?? 0,
        views: args['views'] ?? 0,
        description: args['description'] ?? '',
        releaseDate:
            args['releaseDate'] is DateTime
                ? args['releaseDate'] as DateTime?
                : DateTime.tryParse(args['releaseDate']?.toString() ?? ''),
        status: 'published',
        isVip:
            args['isVip'] == true ||
            args['isVip'] == 1 ||
            args['isVip']?.toString() == '1',
        subtitles: subtitles.toList(),
        qualities: qualities.toList(),
      );

      // ========================================================
      // LISTENER PLAYER
      // ========================================================

      _listenPlayer();

      // ========================================================
      // SYNC STATE SECEPATNYA
      // ========================================================

      _syncExistingPlayerState();

      // ========================================================
      // HISTORY
      // ========================================================

      startHistorySync();

      // ========================================================
      // PASTIKAN PLAYER PLAY
      // ========================================================

      if (!player!.state.playing) {
        await player!.play();
      }

      // ========================================================
      // SYNC LAGI SETELAH PLAY
      // ========================================================

      _syncExistingPlayerState();

      // ========================================================
      // SUBTITLE
      // ========================================================
      //
      // Jalankan setelah player sudah aktif.
      // Jangan blok playback.
      //

      if (subtitles.isNotEmpty) {
        unawaited(_prepareMixSubtitles());
      }

      // ========================================================
      // OVERLAY
      // ========================================================

      showOverlay();

      return;
    }

    // ==========================================================
    // MODE NORMAL
    // ==========================================================
    //
    // SEMUA LOGIC PLAYER LAMA TETAP DI SINI
    //

    title.value = args["title"] ?? "";

    resumeSeconds = args["resumeSeconds"] ?? 0;

    final episodeArg = args["episode"];

    if (episodeArg is WatchHistoryModel) {
      // ===========================
      // Continue Watching
      // ===========================

      final history = episodeArg;

      resumeSeconds = history.watchedSeconds;

      episode = EpisodeModel(
        id: history.episodeId,
        movieId: history.movieId,
        title: history.episodeTitle,
        videoUrl: history.videoUrl,
        episodeNumber: history.episodeNumber,
        duration: history.duration,
        views: history.views,
        description: history.description,
        releaseDate: history.releaseDate,
        status: history.status,
        isVip: history.isVip,
        subtitles: history.subtitles,
        qualities: history.qualities,
      );

      title.value = history.episodeTitle;
      poster.value = history.poster;
      currentEpisodeId.value = history.episodeId;

      subtitles.assignAll(history.subtitles);
      qualities.assignAll(history.qualities);

      currentSubtitle.value = history.subtitles.firstWhereOrNull(
        (e) => e.id == history.subtitleId,
      );

      currentSubtitle.value ??=
          history.subtitles.isNotEmpty ? history.subtitles.first : null;

      final stream = history.qualities.firstWhereOrNull(
        (e) => e.id == history.streamId?.toString(),
      );

      if (stream != null) {
        selectedQuality.value = stream.quality;
        url = ApiConfig.baseUrl + stream.playlist;
      } else if (history.qualities.isNotEmpty) {
        selectedQuality.value = history.qualities.first.quality;

        url =  history.qualities.first.playlist;
      } else {
        url =  history.videoUrl;
      }

      episodes.assignAll(episodeArg.episodes);

      final index = episodes.indexWhere((e) => e.id == history.episodeId);

      if (index >= 0) {
        currentEpisodeIndex.value = index;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(index);
          }
        });
      }

      synopsis.value = episodeArg.synopsis;

      cast.assignAll(episodeArg.cast);
    } else if (episodeArg is EpisodeModel) {
      // ===========================
      // Normal Movie Detail
      // ===========================

      episode = episodeArg;

      currentEpisodeId.value = episode.id;

      subtitles.assignAll(episode.subtitles);

      qualities.assignAll(episode.qualities ?? []);

      if (qualities.isNotEmpty) {
        url = qualities.first.playlist;
      } else {
        url =  episode.videoUrl;
      }

      episodes.assignAll((args["episodes"] as List<EpisodeModel>?) ?? []);

      final index = episodes.indexWhere((e) => e.id == episode.id);

      if (index >= 0) {
        currentEpisodeIndex.value = index;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(index);
          }
        });
      }

      final movie = args["movie"] as MovieModel?;
      if (movie != null) {
        synopsis.value = movie.synopsis;
        cast.value = movie.cast.split(',').toList();
      }
       poster.value = movie!.poster;
    }

    // ==========================================================
    // PLAYER NORMAL
    // ==========================================================

    player = Player();

    videoController = VideoController(player!);

    _listenPlayer();

    playEpisode();

    showOverlay();

    startHistorySync();
  }

  Future<void> saveHistory() async {
    final subtitleId = currentSubtitle.value?.id;

    final streamId =
        qualities
            .firstWhereOrNull((e) => e.quality == selectedQuality.value)
            ?.id;

    await historyRepository.updateHistory(
      episodeId: episode.id,
      seconds: player!.state.position.inSeconds,
      subtitleId: subtitleId.toString(),
      streamId: streamId,
    );

    if (Get.isRegistered<HistoryController>()) {
      Get.find<HistoryController>().refreshHistory();
    }
  }

  void _listenPlayer() {
    // Bersihkan listener lama milik controller ini.
    for (final subscription in _playerSubscriptions) {
      unawaited(subscription.cancel());
    }
    _playerSubscriptions.clear();

    final p = player;

    if (p == null) {
      return;
    }

    _playerSubscriptions.add(
      p.stream.playing.listen((value) {
        isPlaying.value = value;
      }),
    );

    _playerSubscriptions.add(
      p.stream.buffering.listen((value) {
        isBuffering.value = value;
      }),
    );

    _playerSubscriptions.add(
      p.stream.position.listen((value) {
        // debugPrint('[PLAYER POSITION EVENT] $value');

        position.value = value;

        if (cues.isEmpty) {
          currentSubtitleText.value = "";
          return;
        }

        while (currentIndex < cues.length && value > cues[currentIndex].end) {
          currentIndex++;
        }

        if (currentIndex >= cues.length) {
          currentSubtitleText.value = "";
          return;
        }

        final cue = cues[currentIndex];

        if (value >= cue.start && value <= cue.end) {
          currentSubtitleText.value = cue.text;
        } else {
          currentSubtitleText.value = "";
        }
      }),
    );

    _playerSubscriptions.add(
      p.stream.duration.listen((value) {
        duration.value = value;
      }),
    );

    _playerSubscriptions.add(
      p.stream.completed.listen((value) async {
        isCompleted.value = value;

        if (!value) {
          return;
        }

        await saveHistoryIfLoggedIn();

        if (Get.isRegistered<HistoryController>()) {
          Get.find<HistoryController>().refreshHistory();
        }
      }),
    );

    _playerSubscriptions.add(
      p.stream.buffer.listen((value) {
        buffer.value = value;
      }),
    );

    _playerSubscriptions.add(
      p.stream.tracks.listen((tracks) {
        videoTracks.assignAll(tracks.video);
      }),
    );
  }

  Future<void> playEpisode() async {
    // ========================================================
    // NON VIP → BATAS MAKSIMAL 480p
    // ========================================================

    if (!isVipUser && qualities.isNotEmpty) {
      final allowed = highestAllowedQuality;

      if (allowed != null) {
        selectedQuality.value = allowed.quality;

        url = ApiConfig.baseUrl + allowed.playlist;
      }
    }

    await player?.open(Media(url), play: false);

    await cacheSubtitles();

    // Jika belum ada subtitle yang direstore
    currentSubtitle.value ??= subtitles.isNotEmpty ? subtitles.first : null;

    if (currentSubtitle.value != null) {
      await changeSubtitle(currentSubtitle.value);
    }

    final videoDuration = await player?.stream.duration.firstWhere(
      (d) => d > Duration.zero,
    );

    final position = Duration(seconds: resumeSeconds);

    if (resumeSeconds > 5 &&
        videoDuration != null &&
        position < videoDuration) {
      await Future.delayed(const Duration(milliseconds: 300));

      await player?.seek(position);
    }

    await player?.play();
  }

  Future<void> onEpisodeChanged(int index) async {
    if (index == currentEpisodeIndex.value) {
      return;
    }

    if (index < 0 || index >= episodes.length) {
      return;
    }

    final nextEpisode = episodes[index];
    final auth = Get.find<AccountController>();

    if (nextEpisode.isVip && !auth.isVip.value) {
      // Kembalikan ke episode sebelumnya
      await pageController.animateToPage(
        currentEpisodeIndex.value,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );

      // Popup VIP
      Get.generalDialog(
        barrierDismissible: true,
        barrierLabel: "VIP",
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => const VipUpgradeView(),
      );

      return;
    }

    currentEpisodeIndex.value = index;

    await changeEpisode(nextEpisode);
  }

  Future<void> changeEpisode(EpisodeModel newEpisode) async {
    // =========================================
    // GUARD: jangan proses dua episode sekaligus
    // =========================================
    if (_changingEpisode) return;

    // =========================================
    // GUARD VIP
    // =========================================
    final auth = Get.find<AccountController>();

    if (newEpisode.isVip && !auth.isVip.value) {
      Get.generalDialog(
        barrierDismissible: true,
        barrierLabel: "VIP",
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => const VipUpgradeView(),
      );

      return;
    }

    _changingEpisode = true;

    try {
      // =========================================
      // Simpan progress episode sebelumnya
      // =========================================
      if (player != null) {
        await saveHistory();
      }

      isCompleted.value = false;
      isBuffering.value = true;

      viewCounted = false;
      _lastSyncedSecond = 0;

      episode = newEpisode;

      currentEpisodeId.value = newEpisode.id;

      title.value = newEpisode.title;

      resumeSeconds = 0;

      // =========================================
      // Subtitle
      // =========================================
      subtitles.assignAll(newEpisode.subtitles);

      currentSubtitle.value = subtitles.isNotEmpty ? subtitles.first : null;

      cues.clear();
      currentSubtitleText.value = "";
      currentIndex = 0;

      // =========================================
      // Quality
      // =========================================
      qualities.assignAll(newEpisode.qualities ?? []);

      if (qualities.isNotEmpty) {
        if (!isVipUser) {
          // ======================================================
          // NON VIP → MAKSIMAL 480p
          // ======================================================
          final allowed = highestAllowedQuality;

          if (allowed != null) {
            selectedQuality.value = allowed.quality;

            url = allowed.playlist;
          } else {
            selectedQuality.value = "Auto";

            url =  newEpisode.videoUrl;
          }
        } else {
          // ======================================================
          // VIP → QUALITY NORMAL
          // ======================================================

          selectedQuality.value = qualities.first.quality;

          url = ApiConfig.baseUrl + qualities.first.playlist;
        }
      } else {
        selectedQuality.value = "Auto";

        url =  newEpisode.videoUrl;
      }

      // =========================================
      // Ganti video
      // =========================================
      await player?.open(Media(url), play: false);

      // =========================================
      // Tunggu duration tersedia
      // =========================================
      await player?.stream.duration.firstWhere(
        (duration) => duration > Duration.zero,
      );

      // =========================================
      // Cache subtitle
      // =========================================
      await cacheSubtitles();

      if (currentSubtitle.value != null) {
        await changeSubtitle(currentSubtitle.value);
      }

      // =========================================
      // Baru play setelah semuanya siap
      // =========================================
      await player?.play();

      showOverlay();
    } finally {
      _changingEpisode = false;
    }
  }

  Future<void> playPause() async {
    showOverlay();

    final p = player;

    if (p == null) {
      return;
    }

    try {
      if (p.state.playing) {
        await p.pause();
      } else {
        await p.play();
      }

      _syncExistingPlayerState();
    } catch (e) {
      debugPrint('[PLAYER] PLAY PAUSE ERROR: $e');
    }
  }

  Future<void> seek(Duration value) async {
    showOverlay();
    await player?.seek(value);
  }

  Future<void> forward() async {
    final next = position.value + const Duration(seconds: 10);

    await player?.seek(next);

    controlsVisible.value = false;
    _overlayTimer?.cancel();

    forwardSeconds.value += 10;
    showForwardAnimation.value = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      showForwardAnimation.value = false;
      forwardSeconds.value = 0;
    });

    // showOverlay();
  }

  Future<void> backward() async {
    final prev = position.value - const Duration(seconds: 10);

    await player?.seek(prev.isNegative ? Duration.zero : prev);

    controlsVisible.value = false;
    _overlayTimer?.cancel();

    backwardSeconds.value += 10;
    showBackwardAnimation.value = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      showBackwardAnimation.value = false;
      backwardSeconds.value = 0;
    });

    // showOverlay();
  }

  Future<void> setSpeed(double speed) async {
    playbackSpeed.value = speed;

    await player?.setRate(speed);
  }

  // void startSeeking() {
  //   isSeeking.value = true;
  //   _overlayTimer?.cancel();
  // }

  // void updateSeeking(Duration value) {
  //   seekPosition.value = value;
  // }

  // Future<void> endSeeking() async {
  //   isSeeking.value = false;
  //   await player.seek(seekPosition.value);
  //   showOverlay();
  // }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');

    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) {
      return "$h:${two(m)}:${two(s)}";
    }

    return "${two(m)}:${two(s)}";
  }

  void toggleLock() {
    isLocked.toggle();
  }

  Future<void> toggleFullscreen() async {
    isFullscreen.toggle();

    // nanti step berikutnya
  }

  // Future<void> skipIntro() async {
  //   await player.seek(introEnd.value);
  // }

  // Future<void> enterPip() async {}

  void showOverlay() {
    controlsVisible.value = true;

    _overlayTimer?.cancel();

    _overlayTimer = Timer(const Duration(seconds: 4), () {
      if (isScrubbing.value) {
        showOverlay(); // tunggu sampai scrubbing selesai
        return;
      }

      controlsVisible.value = false;
    });
  }

  void toggleOverlay() {
    if (controlsVisible.value) {
      controlsVisible.value = false;
      _overlayTimer?.cancel();
    } else {
      showOverlay();
    }
  }

  void startScrubbing() {
    isScrubbing.value = true;
    scrubPosition.value = position.value;

    showSeek.value = true;
    seekDelta.value = 0;
  }

  void updateScrubbing(double delta) {
    final ms = (delta * 120).round();

    scrubPosition.value += Duration(milliseconds: ms);

    if (scrubPosition.value < Duration.zero) {
      scrubPosition.value = Duration.zero;
    }

    if (scrubPosition.value > duration.value) {
      scrubPosition.value = duration.value;
    }

    seekDelta.value = scrubPosition.value.inSeconds - position.value.inSeconds;
  }

  Future<void> endScrubbing() async {
    isScrubbing.value = false;
    await player?.seek(scrubPosition.value);

    showSeek.value = false;
    showOverlay();
  }

  void showSpeedDialog() {
    SpeedDialog.show(this);
  }

  void showSubtitleDialog() {
    SubtitleDialog.show(this);
  }

  void showQualityDialog() {
    QualityDialog.show(this);
  }

  void showAudioDialog() {
    // AudioDialog.show(this);
  }

  // void showBrightnessDialog() {
  //   // BrightnessDialog.show(this);
  // }

  void showEpisodeDialog() {
    EpisodeDialog.show(this);
  }

  Future<void> changeQuality(QualityModel quality) async {
    // ========================================================
    // VIP LOCK
    // ========================================================

    if (isQualityLocked(quality)) {
      Get.generalDialog(
        barrierDismissible: true,
        barrierLabel: "VIP",
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => const VipUpgradeView(),
      );

      return;
    }

    // ========================================================
    // AUTO
    // ========================================================

    if (quality.quality == "Auto") {
      // VIP → Auto benar-benar Auto
      if (isVipUser) {
        selectedQuality.value = "Auto";

        await player?.setVideoTrack(VideoTrack.auto());

        return;
      }

      // ======================================================
      // NON VIP → AUTO TETAP MAKSIMAL 480p
      // ======================================================

      final allowed = highestAllowedQuality;

      if (allowed == null) {
        return;
      }

      selectedQuality.value = allowed.quality;

      final track = player?.state.tracks.video.firstWhere(
        (t) => t.h == allowed.height,
        orElse: () => VideoTrack.auto(),
      );

      if (track != null) {
        await player?.setVideoTrack(track);
      }

      return;
    }

    // ========================================================
    // QUALITY NORMAL
    // ========================================================

    selectedQuality.value = quality.quality;

    final track = player?.state.tracks.video.firstWhere(
      (t) => t.h == quality.height,
      orElse: () => VideoTrack.auto(),
    );

    if (track != null) {
      await player?.setVideoTrack(track);
    }
  }

  void startHistorySync() {
    _historyTimer?.cancel();

    _historyTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!isUserLoggedIn) {
        return;
      }

      if (!player!.state.playing) return;

      final current = player?.state.position.inSeconds;

      if (!viewCounted && current! >= 10) {
        viewCounted = true;

        await historyRepository.addEpisodeView(episodeId: episode.id);
      }

      if ((current! - _lastSyncedSecond).abs() < 10) return;

      _lastSyncedSecond = current;

      final subtitleId = currentSubtitle.value?.id;

      final streamId =
          qualities
              .firstWhereOrNull((e) => e.quality == selectedQuality.value)
              ?.id;

      await historyRepository.updateHistory(
        episodeId: episode.id,
        seconds: current,
        subtitleId: subtitleId.toString(),
        streamId: streamId,
      );

      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().refreshHistory();
      }
    });
  }

  void onDoubleTapDown(TapDownDetails details) {
    doubleTapPosition = details;
  }

  void onDoubleTap() {
    if (doubleTapPosition == null) return;

    // Sembunyikan overlay player
    controlsVisible.value = false;
    _overlayTimer?.cancel();

    final width = Get.width;

    if (doubleTapPosition!.localPosition.dx < width / 2) {
      backward();
    } else {
      forward();
    }
  }

  void onPanStart(DragStartDetails details) {
    start = details.localPosition;

    dragType = DragType.none;

    isLeftSide = details.localPosition.dx < Get.width / 2;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (start == null) return;

    if (dragType == DragType.none) {
      final dx = details.localPosition.dx - start!.dx;
      final dy = details.localPosition.dy - start!.dy;

      if (dx.abs() < 10 && dy.abs() < 10) return;

      if (dx.abs() > dy.abs()) {
        dragType = DragType.horizontal;
        startScrubbing();
      } else {
        dragType = isLeftSide ? DragType.brightness : DragType.volume;
      }
    }

    switch (dragType) {
      case DragType.horizontal:
        updateScrubbing(details.delta.dx);
        break;

      case DragType.brightness:
        // updateBrightness(-details.delta.dy);
        break;

      case DragType.volume:
        // updateSystemVolume(-details.delta.dy);
        break;

      case DragType.none:
        break;
    }
  }

  Future<void> onPanEnd(DragEndDetails details) async {
    if (dragType == DragType.horizontal) {
      await endScrubbing();
    }

    dragType = DragType.none;

    start = null;
  }

  void _syncExistingPlayerState() {
    final p = player;

    if (p == null) {
      return;
    }

    final state = p.state;

    // ==========================================================
    // SYNC STATE PLAYER YANG SUDAH BERJALAN
    // ==========================================================

    isPlaying.value = state.playing;
    isBuffering.value = state.buffering;
    isCompleted.value = state.completed;

    position.value = state.position;
    duration.value = state.duration;
    buffer.value = state.buffer;

    videoTracks.assignAll(state.tracks.video);

    debugPrint(
      '[PLAYER] SYNC EXISTING PLAYER '
      'playing=${state.playing} '
      'position=${state.position} '
      'duration=${state.duration} '
      'buffer=${state.buffer}',
    );
  }

  Future<void> _prepareMixSubtitles() async {
    try {
      await cacheSubtitles();

      if (subtitles.isEmpty) {
        return;
      }

      currentSubtitle.value ??= subtitles.first;

      if (currentSubtitle.value != null) {
        await changeSubtitle(currentSubtitle.value);
      }
    } catch (e) {
      debugPrint('[PLAYER MIX] SUBTITLE ERROR: $e');
    }
  }

  // ==========================================================
  // QUALITY ACCESS
  // ==========================================================

  bool get isVipUser {
    final auth = Get.find<AccountController>();
    return auth.isVip.value;
  }

  bool isQualityLocked(QualityModel quality) {
    if (isVipUser) {
      return false;
    }

    // Auto selalu boleh.
    if (quality.quality.toLowerCase() == 'auto') {
      return false;
    }

    // Hitung hanya kualitas asli, tanpa Auto.
    final realQualities =
        qualities.where((q) => q.quality.toLowerCase() != 'auto').toList();

    // Kalau cuma ada 1 kualitas asli,
    // kualitas tersebut sama dengan Auto → jangan di-lock.
    if (realQualities.length <= 1) {
      return false;
    }

    // Kalau ada beberapa kualitas asli,
    // non-VIP maksimal 480p.
    return (quality.height ?? 0) > 480;
  }

  QualityModel? get highestAllowedQuality {
    final realQualities =
        qualities.where((q) => q.quality.toLowerCase() != 'auto').toList();

    if (realQualities.isEmpty) {
      return null;
    }

    // Cuma 1 real quality → boleh walaupun >480p.
    if (realQualities.length == 1) {
      return realQualities.first;
    }

    // Ada lebih dari 1 real quality → non-VIP maksimal 480p.
    final allowed = realQualities.where((q) => (q.height ?? 0) <= 480).toList();

    if (allowed.isEmpty) {
      return null;
    }

    allowed.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));

    return allowed.first;
  }

  bool get isUserLoggedIn {
    final auth = Get.find<AccountController>();
    return auth.isLogin;
  }

  Future<void> saveHistoryIfLoggedIn() async {
    if (!isUserLoggedIn) {
      return;
    }

    if (player == null || episode.id <= 0) {
      return;
    }

    try {
      await saveHistory();
    } catch (e) {
      debugPrint('[PLAYER] SAVE HISTORY ERROR: $e');
    }
  }

  // Future<void> updateBrightness(double delta) async {
  //   brightness.value = (brightness.value + delta / 300).clamp(0.0, 1.0);

  //   await ScreenBrightness().setScreenBrightness(brightness.value);

  //   showBrightness.value = true;

  //   _brightnessTimer?.cancel();

  //   _brightnessTimer = Timer(
  //     const Duration(seconds: 1),
  //     () => showBrightness.value = false,
  //   );
  // }

  // Future<void> updateSystemVolume(double delta) async {
  //   volume.value = (volume.value + delta / 3).clamp(0, 100);

  //   await VolumeController.instance.setVolume(volume.value / 100);

  //   showVolume.value = true;

  //   _volumeTimer?.cancel();

  //   _volumeTimer = Timer(
  //     const Duration(seconds: 1),
  //     () => showVolume.value = false,
  //   );
  // }

  // Future<void> _initSystemValues() async {
  //   brightness.value = await ScreenBrightness().current;

  //   volume.value = (await VolumeController.instance.getVolume()) * 100;
  // }

  Future<void> cacheSubtitles() async {
    final dir = await getTemporaryDirectory();

    final folder = Directory('${dir.path}/subtitles/${currentEpisodeId.value}');

    await folder.create(recursive: true);

    for (final subtitle in subtitles) {
      final file = File('${folder.path}/${subtitle.languageCode}.vtt');

      if (!await file.exists()) {
        final path = subtitle.subtitlePath.trim();

        final downloadUrl =
            path.startsWith('http://') || path.startsWith('https://')
                ? path
                : '${ApiConfig.baseUrl}${path.replaceFirst(RegExp(r'^/'), '')}';

        debugPrint('[SUBTITLE] DOWNLOAD $downloadUrl');

        await Dio().download(downloadUrl, file.path);
      }

      subtitleCache[subtitle.languageCode] = file.path;
    }
  }

  Future<List<SubtitleCue>> parseVtt(String path) async {
    final file = File(path);

    final lines = await file.readAsLines();

    final cues = <SubtitleCue>[];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('-->')) {
        final split = lines[i].split('-->');

        final start = parse(split[0].trim());
        final end = parse(split[1].trim());

        final text = lines[i + 1];

        cues.add(SubtitleCue(start: start, end: end, text: text));
      }
    }

    return cues;
  }

  Future<void> changeSubtitle(EpisodeSubtitle? subtitle) async {
    currentSubtitle.value = subtitle;

    currentSubtitleText.value = '';
    currentIndex = 0;

    cues.clear();

    if (subtitle == null) {
      return;
    }

    try {
      final dir = await getTemporaryDirectory();

      final folder = Directory(
        '${dir.path}/subtitles/${currentEpisodeId.value}',
      );

      await folder.create(recursive: true);

      final file = File('${folder.path}/${subtitle.languageCode}.vtt');

      // ========================================================
      // PASTIKAN FILE LOKAL ADA
      // ========================================================

      if (!await file.exists()) {
        final path = subtitle.subtitlePath.trim();

        final downloadUrl =
            path.startsWith('http://') || path.startsWith('https://')
                ? path
                : '${ApiConfig.baseUrl}${path.replaceFirst(RegExp(r'^/'), '')}';

        debugPrint(
          '[SUBTITLE] DOWNLOAD ON SELECT '
          '$downloadUrl',
        );

        await Dio().download(downloadUrl, file.path);
      }

      // ========================================================
      // PARSE FILE LOKAL
      // ========================================================

      cues.value = await parseVtt(file.path);

      subtitleCache[subtitle.languageCode] = file.path;

      debugPrint(
        '[SUBTITLE] LOADED '
        '${subtitle.languageCode} '
        'cues=${cues.length}',
      );
    } catch (e) {
      debugPrint(
        '[SUBTITLE] LOAD ERROR '
        '${subtitle.languageCode}: $e',
      );

      cues.clear();
      currentSubtitleText.value = '';
    }
  }

  Future<void> cleanOldSubtitleCache() async {
    final dir = await getTemporaryDirectory();

    final root = Directory("${dir.path}/subtitles");

    if (!await root.exists()) return;

    final now = DateTime.now();

    await for (final entity in root.list()) {
      if (entity is! Directory) continue;

      final stat = await entity.stat();

      final age = now.difference(stat.modified);

      if (age.inDays >= 7) {
        await entity.delete(recursive: true);
      }
    }
  }
}
