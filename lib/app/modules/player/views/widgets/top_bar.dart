import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class TopBar extends GetView<PlayerController> {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.controlsVisible.value) {
        return const SizedBox();
      }

      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    controller.title.value.capitalize??'',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.toggleLock,
                  icon: Icon(
                    controller.isLocked.value
                        ? Icons.lock
                        : Icons.lock_open,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}