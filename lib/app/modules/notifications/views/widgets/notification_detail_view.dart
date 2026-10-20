
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helpers/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import '../../controllers/notifications_controller.dart';

class NotificationDetailView extends GetView<NotificationsController> {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.contentColorBlack,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorBlack,
        foregroundColor: Colors.white,
        title: const Text('Detail Notifikasi'),
      ),
      body: FutureBuilder<NotificationModel>(
        future: controller.loadDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_off_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Detail notifikasi tidak dapat dimuat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          final item = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.amber,
                  size: 42,
                ),
                const SizedBox(height: 20),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.createdAt,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}