import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../controllers/mix_controller.dart';

class MixVideoPlayer extends StatelessWidget {
  final MixController controller;
  final int index;
  const MixVideoPlayer({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final videoController = controller.getVideoController(index);
      final isReady = controller.readyPlayers.contains(index);
      // final isInitializing = controller.initializingPlayers.contains(index);
      // ====================================================== // BELUM ADA PLAYER / BELUM READY // ======================================================
      if (videoController == null || !isReady) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.contentColorYellow,
              ),
            ),
          ),
        );
      }
      // ====================================================== // VIDEO // ======================================================
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.togglePlayPause(index);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Video(
              controller: videoController,
              fit: BoxFit.fill,
              controls: NoVideoControls,
            ), // ================================================== // BUFFERING // ==================================================
            StreamBuilder<bool>(
              stream: videoController.player.stream.buffering,
              initialData: videoController.player.state.buffering,
              builder: (context, snapshot) {
                final buffering = snapshot.data ?? false;
                if (!buffering) {
                  return const SizedBox.shrink();
                }
                return const Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.contentColorYellow,
                    ),
                  ),
                );
              },
            ),
            // ================================================== // PLAY / PAUSE INDICATOR // ==================================================
            StreamBuilder<bool>(
              stream: videoController.player.stream.playing,
              initialData: videoController.player.state.playing,
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return Center(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: playing ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
