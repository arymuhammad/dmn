import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';
import 'player_progress.dart';

class BottomControls extends GetView<PlayerController> {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.controlsVisible.value) {
        return const SizedBox();
      }

      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlayerProgress(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Text(
                      controller.format(controller.position.value),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),

                    Obx(() {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.selectedQuality.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),

                    const Spacer(),
                    Text(
                      controller.format(controller.duration.value),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _tool(Icons.list, "Episode", controller.showEpisodeDialog),

                    // _tool(Icons.brightness_6, "Light",
                    //     controller.showBrightnessDialog),
                    _tool(
                      Icons.graphic_eq,
                      "Audio",
                      controller.showAudioDialog,
                    ),

                    _tool(
                      Icons.closed_caption,
                      "CC",
                      controller.showSubtitleDialog,
                    ),

                    _tool(
                      Icons.high_quality,
                      "HD",
                      controller.showQualityDialog,
                    ),

                    Obx(
                      () => _tool(
                        Icons.speed,
                        "${controller.playbackSpeed.value}x",
                        controller.showSpeedDialog,
                      ),
                    ),

                    // IconButton(
                    //   onPressed: controller.toggleFullscreen,
                    //   icon: const Icon(Icons.fullscreen, color: Colors.white),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }

  Widget _tool(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
