import 'package:dmn_play/app/data/helpers/app_icon.dart';
import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../notifications/views/widgets/notification_bell.dart';

class HomeAppBar extends GetView<AccountController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
          AppIcon(height: 35, width: 35),
          const SizedBox(width: 8),

          const Text(
            'DMN Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),

          NotificationBell(
            onTap: () {
              final user = controller.user.value;
              if (user == null) {
                Get.toNamed(Routes.LOGIN);
                return;
              }

              Get.toNamed(Routes.NOTIFICATIONS);
            },
          ),
        ],
      ),
    );
  }
}
