import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/player_controller.dart';

class SubtitleDialog {
  static void show(PlayerController controller) {
    Get.bottomSheet(
      Container(
        color: const Color(0xff181818),
        child: SafeArea(
          child: Obx(
            () => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.subtitles.length + 1,
              itemBuilder: (context, index) {
                // Subtitle Off
                if (index == 0) {
                  final selected = controller.currentSubtitle.value == null;

                  return ListTile(
                    leading: const Icon(
                      Icons.subtitles_off,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      "Off",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        selected
                            ? Icon(
                              Icons.check_circle,
                              color: AppColors.contentColorYellow,
                            )
                            : null,
                    onTap: () async {
                      await controller.changeSubtitle(null);
                      Get.back();
                    },
                  );
                }

                final subtitle = controller.subtitles[index - 1];

                final selected =
                    controller.currentSubtitle.value?.languageCode ==
                    subtitle.languageCode;

                return ListTile(
                  leading: const Icon(Icons.subtitles, color: Colors.white70),
                  title: Text(
                    subtitle.languageName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    subtitle.languageCode.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing:
                      selected
                          ? Icon(
                            Icons.check_circle,
                            color: AppColors.contentColorYellow,
                          )
                          : null,
                  onTap: () async {
                    await controller.changeSubtitle(subtitle);
                    Get.back();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
