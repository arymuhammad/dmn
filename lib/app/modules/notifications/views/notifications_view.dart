import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helpers/app_colors.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentColorBlack,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorBlack,
        foregroundColor: Colors.white,
        title: const Text('Notifikasi'),
        actions: [
          Obx(
            () =>
                controller.unreadCount > 0
                    ? TextButton(
                      onPressed: controller.markAllAsRead,
                      child: const Text(
                        'Baca semua',
                        style: TextStyle(color: Colors.amber),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    color: Colors.white54,
                    size: 52,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: controller.loadNotifications,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 140),
                Icon(Icons.notifications_none, size: 64, color: Colors.white38),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder:
                (_, __) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      item.isRead
                          ? Colors.white10
                          : Colors.amber.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: item.isRead ? Colors.white54 : Colors.amber,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        item.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (item.createdAt.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.createdAt,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing:
                    item.isRead
                        ? null
                        : const Icon(
                          Icons.circle,
                          color: Colors.amber,
                          size: 9,
                        ),
                onTap: () async {
                  await controller.markAsRead(item);
                  Get.toNamed('/notifications/${item.id}');
                },
              );
            },
          ),
        );
      }),
    );
  }
}
