import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../controllers/player_controller.dart';

class PlayerVideo extends StatelessWidget {
  final PlayerController controller;

  const PlayerVideo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.episodes.isEmpty) {
      return _buildVideo();
    }

    return PageView.builder(
      controller: controller.pageController,
      scrollDirection: Axis.vertical,
      itemCount: controller.episodes.length,
      onPageChanged: controller.onEpisodeChanged,
      itemBuilder: (_, index) => _buildVideo(),
    );
  }

  Widget _buildVideo() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onTap: controller.toggleOverlay,

      onDoubleTapDown: controller.onDoubleTapDown,
      onDoubleTap: controller.onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // =========================
          // VIDEO
          // =========================
          Video(
            controller: controller.videoController!,
            controls: NoVideoControls,
            subtitleViewConfiguration: const SubtitleViewConfiguration(
              visible: false,
            ),
          ),

          // =========================
          // BUFFERING OVERLAY
          // =========================
          Obx(() {
            if (!controller.isBuffering.value) {
              return const SizedBox.shrink();
            }
            return Container(
              color: Colors.black.withValues(alpha: 0.15),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            );
          }),

          // =========================
          // SUBTITLE
          // =========================
          Positioned(
            left: 24,
            right: 24,
            bottom: Get.height * 0.22,
            child: Obx(() {
              if (controller.currentSubtitleText.value.isEmpty) {
                return const SizedBox();
              }

              return Text(
                controller.currentSubtitleText.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

