import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class OverlayBackground extends GetView<PlayerController> {
  const OverlayBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: controller.controlsVisible.value ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            color: Colors.black45,
          ),
        ),
      );
    });
  }
}