import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class GestureLayer extends GetView<PlayerController> {
  const GestureLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      // Tap biasa → tampil/sembunyikan controls
      onTap: controller.toggleOverlay,

      // Double tap → seek ±10 detik
      onDoubleTapDown: controller.onDoubleTapDown,
      onDoubleTap: controller.onDoubleTap,

      // onPanStart: controller.onPanStart,
      // onPanUpdate: controller.onPanUpdate,
      // onPanEnd: controller.onPanEnd,

      child: const SizedBox.expand(),
    );
  }
}
