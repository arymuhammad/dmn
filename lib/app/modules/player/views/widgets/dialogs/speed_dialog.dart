import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/player_controller.dart';

class SpeedDialog {
  static void show(PlayerController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xff181818),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Obx(
            () => ListView(
              shrinkWrap: true,
              children: [
                for (final speed in [
                  0.5,
                  0.75,
                  1.0,
                  1.25,
                  1.5,
                  1.75,
                  2.0,
                ])
                  ListTile(
                    title: Text(
                      "${speed}x",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: controller.playbackSpeed.value == speed
                        ? const Icon(Icons.check, color: Colors.red)
                        : null,
                    onTap: () async {
                      await controller.setSpeed(speed);
                      Get.back();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}