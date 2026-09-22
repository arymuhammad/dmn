import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class CenterControls extends GetView<PlayerController> {
  const CenterControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.controlsVisible.value) {
        return const SizedBox();
      }

      return Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(
              icon: Icons.replay_10_rounded,
              size: 28,
              onTap: controller.backward,
            ),

            const SizedBox(width: 38),

            InkWell(
              onTap: controller.playPause,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .35),
                  shape: BoxShape.circle,
                  // border: Border.all(color: Colors.white.withValues(alpha: .15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  controller.isPlaying.value
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

            const SizedBox(width: 38),

            _controlButton(
              icon: Icons.forward_10_rounded,
              size: 28,
              onTap: controller.forward,
            ),
          ],
        ),
      );
    });
  }

}
  Widget _controlButton({
  required IconData icon,
  required VoidCallback onTap,
  double size = 28,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .35),
        shape: BoxShape.circle,
        // border: Border.all(
        //   color: Colors.white.withValues(alpha: .12),
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
    ),
  );
}

