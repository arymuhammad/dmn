import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class SeekOverlay extends GetView<PlayerController> {
  const SeekOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showSeek.value) {
        return const SizedBox();
      }

      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.seekDelta.value >= 0
                    ? Icons.fast_forward
                    : Icons.fast_rewind,
                color: Colors.white,
                size: 44,
              ),
              const SizedBox(height: 10),
              Text(
                "${controller.seekDelta.value > 0 ? "+" : ""}${controller.seekDelta.value}s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${controller.format(controller.position.value)} → ${controller.format(controller.scrubPosition.value)}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    });
  }
}
