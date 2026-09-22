import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/player_controller.dart';

class QualityDialog {
  static void show(PlayerController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xff181818),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Obx(
            () => ListView(
              shrinkWrap: true,
              children: [
                for (final q in controller.qualities)
                  ListTile(
                    title: Text(
                      q.quality,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle:
                        q.height != null
                            ? Text(
                              '${q.height}p',
                              style: const TextStyle(color: Colors.grey),
                            )
                            : null,

                    trailing:
                        controller.selectedQuality.value == q.quality
                            ? Icon(Icons.check, color: AppColors.contentColorYellow)
                            : null,

                    onTap: () {
                      controller.selectedQuality.value = q.quality;

                      controller.changeQuality(q);

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
