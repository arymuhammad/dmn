import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogoutDialog {
  static void show({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1C1C),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.white.withValues(alpha: .14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .45),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm'.tr.capitalize ?? '',
                style: TextStyle(
                  color: AppColors.contentColorWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'are you sure you want to log out?'
                    .tr
                    .capitalizeFirst ?? '',
                style: TextStyle(
                  color: AppColors.contentColorWhite.withValues(
                    alpha: .65,
                  ),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Get.back,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppColors.contentColorYellow,
                      side: BorderSide(
                        color: AppColors.contentColorYellow
                            .withValues(alpha: .35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'no'.tr.capitalizeFirst ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.contentColorYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'yes'.tr.capitalizeFirst ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}