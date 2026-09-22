import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class VolumeOverlay extends GetView<PlayerController> {
  const VolumeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showVolume.value) {
        return const SizedBox();
      }

      return Positioned(
        right: 25,
        top: 0,
        bottom: 0,
        child: Center(
          child: Container(
            width: 55,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Icon(Icons.volume_up, color: Colors.white),

                const SizedBox(height: 15),

                Expanded(
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: controller.volume.value,
                      max: 100,
                      onChanged: null,
                    ),
                  ),
                ),

                Text(
                  controller.volume.value.toInt().toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
