import 'package:dmn_play/app/modules/episode_player/controllers/episode_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/helpers/app_colors.dart';
import '../data/helpers/video_source.dart';
import '../modules/episode_player/views/episode_player_view.dart';
import '../modules/navbar/controllers/navbar_controller_controller.dart';
import '../modules/short/controllers/short_controller.dart';

class VideoItem extends StatefulWidget {
  final int index;
  final String path;
  final String subtitleUrl;
  const VideoItem({
    super.key,
    required this.index,
    required this.path,
    required this.subtitleUrl,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController controller;
  // bool showPlayIcon = false;
  bool showControls = false;
  double speed = 1.0;
  // String quality = "720";
  // int audioIndex = 0;
  SubtitleController? subtitleController;
  bool get canShowControls => showControls && controller.value.isInitialized;
  late Worker worker;

  final navbarC = Get.find<NavbarController>();
  final shortC = Get.find<ShortController>();

  @override
  void initState() {
    super.initState();

    subtitleController = SubtitleController(
      subtitleUrl: widget.subtitleUrl,
      subtitleType: SubtitleType.srt,
    );
    controller = VideoPlayerController.asset(widget.path)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {});
        controller.setLooping(true); // 🔥 INI YANG DIPERLUKAN
        controller.play();

        // 🔥 FORCE CHECK SETELAH READY
        Future.delayed(Duration(milliseconds: 100), () {
          _syncPlayback();
        });
      });

    // 🔥 listener tetap
    worker = everAll([navbarC.currentIndex, shortC.currentVideo], (_) {
      _syncPlayback();
    });

    controller.addListener(() async {
      if (!mounted) return;

      final value = controller.value;

      // 🔥 FORCE LOOP MANUAL (backup kalau setLooping gagal)
      if (value.position >= value.duration && value.duration != Duration.zero) {
        await controller.seekTo(Duration.zero);
        await controller.play();
      }

      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ever(navbarC.currentIndex, (tab) {
      if (tab == 1) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _syncPlayback();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _syncPlayback();
    });
  }

  @override
  void dispose() {
    worker.dispose();
    WakelockPlus.disable();
    controller.dispose();
    super.dispose();
  }

  void _syncPlayback() async {
    if (!controller.value.isInitialized) return;

    final isShortTab = navbarC.currentIndex.value == 1;
    final isActive = isShortTab && shortC.currentVideo.value == widget.index;

    if (isActive) {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!controller.value.isPlaying) {
        await controller.play();
        WakelockPlus.enabled;
      }
      // 🔥 kalau sudah di akhir, paksa balik ke awal
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration != Duration.zero) {
        await controller.seekTo(Duration.zero);
      }
    } else {
      if (controller.value.isPlaying) {
        await controller.pause();
        WakelockPlus.disable();
      }
    }
  }
  // void _togglePlay() async {
  //   if (!controller.value.isInitialized) return;

  //   if (controller.value.isPlaying) {
  //     await controller.pause();
  //     setState(() => showPlayIcon = true);
  //   } else {
  //     await controller.play();
  //     setState(() => showPlayIcon = false);
  //   }
  // }

  void showPlayerControls() {
    setState(() {
      showControls = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (controller.value.isPlaying) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void setSpeed(double val) {
    speed = val;
    controller.setPlaybackSpeed(val);
    setState(() {});
  }

  void changeQuality(String quality, VideoSource source) async {
    String url;

    switch (quality) {
      case "360":
        url = source.url360;
        break;
      case "1080":
        url = source.url1080;
        break;
      default:
        url = source.url720;
    }

    final wasPlaying = controller.value.isPlaying;

    await controller.pause();
    await controller.dispose();

    controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true); // 🔥 INI YANG DIPERLUKAN
        if (wasPlaying) controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (subtitleController == null) {
      return VideoPlayer(controller);
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showPlayerControls();
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: SubtitleWrapper(
                  videoPlayerController: controller,
                  subtitleController: subtitleController!,
                  subtitleStyle: const SubtitleStyle(
                    textColor: Colors.white,
                    hasBorder: true,
                  ),
                  videoChild: VideoPlayer(controller),
                ),
              ),
            ),
          ),
        ),

        // 🔥 SEEK BAR
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.contentColorYellow,
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white12,
            ),
          ),
        ),
        // 🔥 EPS BAR
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              final epC = Get.find<EpisodePlayerController>();
              final shortC = Get.find<ShortController>();

              epC.open(shortC.videos, shortC.currentVideo.value);
              epC.openSheet(); // 🔥 INI WAJIB
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, color: Colors.white),
                        Obx(() {
                          final current = shortC.currentVideo.value + 1;
                          final total = shortC.videos.length;

                          return Text(
                            'Ep. $current/$total Watch Now',
                            style: TextStyle(color: Colors.white),
                          );
                        }),
                      ],
                    ),
                    // Arrow
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔥 ICON PLAY/PAUSE CENTER
        Center(
          child: AnimatedOpacity(
            opacity: canShowControls ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !canShowControls,
              child: GestureDetector(
                onTap: () async {
                  if (controller.value.isPlaying) {
                    await controller.pause();
                  } else {
                    await controller.play();

                    setState(() {
                      showControls = false;
                    });
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
