import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../account/views/widget/vip_upgrade_view.dart';
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
                  Builder(
                    builder: (_) {
                      final locked = controller.isQualityLocked(q);

                      final selected =
                          controller.selectedQuality.value == q.quality;

                      return ListTile(
                        // ==================================================
                        // QUALITY
                        // ==================================================
                        title: Row(
                          children: [
                            Text(
                              q.quality,
                              style: TextStyle(
                                color: locked ? Colors.white54 : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // ==============================================
                            // VIP LABEL
                            // ==============================================
                            if (locked) ...[
                              const SizedBox(width: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // ==================================================
                        // RESOLUTION
                        // ==================================================
                        subtitle:
                            q.height != null
                                ? Text(
                                  '${q.height}p',
                                  style: TextStyle(
                                    color:
                                        locked
                                            ? Colors.grey.shade700
                                            : Colors.grey,
                                  ),
                                )
                                : null,

                        // ==================================================
                        // ICON
                        // ==================================================
                        trailing:
                            locked
                                ? const Icon(
                                  Icons.lock_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                )
                                : selected
                                ? Icon(
                                  Icons.check,
                                  color: AppColors.contentColorYellow,
                                )
                                : null,

                        // ==================================================
                        // TAP
                        // ==================================================
                        onTap: () async {
                          // ================================================
                          // QUALITY LOCK
                          // ================================================
                          final locked = controller.isQualityLocked(q);

                          if (locked) {
                            Get.generalDialog(
                              barrierDismissible: true,
                              barrierLabel: "VIP",
                              barrierColor: Colors.black54,
                              pageBuilder:
                                  (_, __, ___) => const VipUpgradeView(),
                            );

                            return;
                          }

                          // ================================================
                          // QUALITY NORMAL
                          // ================================================

                          await controller.changeQuality(q);

                          Get.back();
                        },
                      );
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
