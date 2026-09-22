import 'dart:async';

import 'package:dmn_play/app/data/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/models/home_model.dart';
import '../../home/controllers/home_controller.dart';

class MovieBannerController extends GetxController {
  final HomeController homeController;

  MovieBannerController(this.homeController);

  // ============================================================
  // BANNERS
  // ============================================================

  final RxList<BannerModel> bannerList = <BannerModel>[].obs;

  List<BannerModel> get banners {
    return bannerList;
  }

  // ============================================================
  // CURRENT INDEX
  // ============================================================

  final currentIndex = 0.obs;

  // ============================================================
  // VIDEO
  // ============================================================

  late final Player player;
  late final VideoController videoController;

  final ready = false.obs;

  Timer? _timer;

  bool _disposed = false;

  int _previewRequestId = 0;

  Worker? _homeWorker;

  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  late final PageController pageController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _disposed = false;

    // ==========================================================
    // PAGE CONTROLLER DIBUAT SEKALI
    // ==========================================================

    pageController = PageController(initialPage: 0);

    // ==========================================================
    // PLAYER
    // ==========================================================

    player = Player();

    videoController = VideoController(player);

    player.stream.error.listen((error) {
      if (_disposed) return;

      // debugPrint('BANNER PLAYER ERROR = $error');
    });

    // ==========================================================
    // HOME LISTENER
    // ==========================================================

    _homeWorker = ever<HomeModel?>(homeController.home, (_) {
      if (_disposed) return;

      _onBannersChanged();
    });

    // ==========================================================
    // DATA SUDAH ADA
    // ==========================================================

    if (banners.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;

        _onBannersChanged();
      });
    }

    player.stream.playing.listen((playing) {
      if (_disposed) return;

      // debugPrint('BANNER PLAYING = $playing');
    });

    player.stream.completed.listen((completed) {
      if (_disposed) return;

      if (completed) {
        // debugPrint('BANNER COMPLETED');
      }
    });
  }

  // ============================================================
  // BANNER DATA BERUBAH
  // ============================================================

  void _onBannersChanged() {
    if (_disposed) return;

    final list = homeController.home.value?.banner ?? [];

    bannerList.assignAll(list);

    if (list.isEmpty) {
      currentIndex.value = 0;
      ready.value = false;

      _timer?.cancel();
      player.stop();

      return;
    }

    if (currentIndex.value >= list.length) {
      currentIndex.value = 0;
    }

    final banner = list[currentIndex.value];

    _playCurrentBanner(banner.previewUrl);

    if (list.length > 1) {
      startAutoSlide();
    } else {
      _timer?.cancel();
    }
  }

  // ============================================================
  // AUTO SLIDE
  // ============================================================

  void startAutoSlide() {
    _timer?.cancel();

    if (_disposed) return;

    if (banners.length <= 1) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_disposed) return;

      if (!pageController.hasClients) return;

      if (banners.length <= 1) return;

      final currentPage = pageController.page?.round() ?? 0;

      final nextPage = currentPage + 1;

      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
  }

  // ============================================================
  // PAGE CHANGED
  // ============================================================

  Future<void> onPageChanged(int index) async {
    if (_disposed) return;

    final list = banners;

    if (list.isEmpty) return;

    final bannerIndex = index % list.length;

    currentIndex.value = bannerIndex;

    ready.value = false;

    final requestId = ++_previewRequestId;

    // Tunggu transisi selesai
    await Future.delayed(const Duration(milliseconds: 500));

    if (_disposed) return;

    if (requestId != _previewRequestId) {
      return;
    }

    final currentList = banners;

    if (currentList.isEmpty) {
      return;
    }

    if (currentIndex.value != bannerIndex) {
      return;
    }

    await playPreview(
      currentList[bannerIndex].previewUrl,
      requestId: requestId,
    );
  }

  // ============================================================
  // PLAY CURRENT BANNER
  // ============================================================

  Future<void> _playCurrentBanner(String? url) async {
    if (_disposed) return;

    final requestId = ++_previewRequestId;

    await playPreview(url, requestId: requestId);
  }

  // ============================================================
  // PLAY PREVIEW
  // ============================================================

  Future<void> playPreview(String? url, {required int requestId}) async {
    if (_disposed) return;

    if (requestId != _previewRequestId) {
      return;
    }

    ready.value = false;

    if (url == null || url.isEmpty) {
      return;
    }

    try {
      await player.open(Media(ApiConfig.baseUrl + url), play: false);

      if (_disposed) return;

      if (requestId != _previewRequestId) {
        return;
      }

      await player.setVolume(0);

      if (_disposed) return;

      await player.setPlaylistMode(PlaylistMode.single);

      if (_disposed) return;

      await player.play();

      if (_disposed) return;

      if (requestId != _previewRequestId) {
        return;
      }

      ready.value = true;
    } catch (e) {
      if (_disposed) return;

      debugPrint('PLAY PREVIEW ERROR = $e');

      ready.value = false;
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _disposed = true;

    _previewRequestId++;

    _homeWorker?.dispose();
    _homeWorker = null;

    _timer?.cancel();
    _timer = null;

    ready.value = false;

    // Stop player
    player.stop();

    player.dispose();
    // Dispose PageController terakhir
    pageController.dispose();

    super.onClose();
  }
}
