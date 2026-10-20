import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../controllers/notifications_controller.dart';


class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBell({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationsController>()) {
      if (!Get.isRegistered<NotificationsRepository>()) {
        Get.lazyPut<NotificationsRepository>(
          () => NotificationsRepository(Get.find<ApiClient>()),
        );
      }

      Get.lazyPut<NotificationsController>(
        () => NotificationsController(
          Get.find<NotificationsRepository>(),
        ),
      );
    }

    final controller = Get.find<NotificationsController>();

    return Obx(() {
      final count = controller.unreadCount.value;

      return IconButton(
        onPressed: onTap,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
            if (count > 0)
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}