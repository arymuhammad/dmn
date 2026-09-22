import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class BrightnessOverlay extends GetView<PlayerController> {
  const BrightnessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showBrightness.value) {
        return const SizedBox();
      }

      return Positioned(
        left: 30,
        right: 30,
        top: 120,
        child: IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: controller.showBrightness.value ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.brightness_6_rounded,
                    color: Colors.white,
                    size: 26,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: controller.brightness.value,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
