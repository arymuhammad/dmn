import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:dmn_play/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

class ProfileHeader extends GetView<AccountController> {
  ProfileHeader({super.key});
  final auth = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage:
                  user != null && user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
              child: user == null ? const Icon(Icons.person) : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: () {
                  if (user == null) {
                    Get.toNamed(Routes.LOGIN);
                  } else {
                    auth.logout();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullname ?? "Guest",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user != null ? user.email : "Belum Login",
                      style: const TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user == null
                          ? 'login'.tr.capitalizeFirst ?? ''
                          : 'logout'.tr.capitalizeFirst ?? '',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ],
        ),
      );
    });
  }
}
