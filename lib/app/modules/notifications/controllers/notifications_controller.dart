import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/storage_service.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository repository;

  NotificationsController(this.repository);

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final token = await StorageService.readToken();

    if (token == null || token.isEmpty) {
      notifications.clear();
      unreadCount.value = 0;
      errorMessage.value = 'Silakan login untuk melihat notifikasi.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.getNotifications();
      notifications.assignAll(result);
      unreadCount.value = await repository.getUnreadCount();
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();

      debugPrint('[NOTIFICATIONS ERROR] $e');
      debugPrint('[NOTIFICATIONS STACK] $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel item) async {
    if (item.isRead) return;

    try {
      await repository.markAsRead(item.id);
      await loadNotifications();
    } catch (_) {
      if (unreadCount.value == 0) return;
      Get.snackbar('Gagal', 'Notifikasi belum berhasil ditandai sudah dibaca.');
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    try {
      await repository.markAllAsRead();
      await loadNotifications();
    } catch (_) {
      Get.snackbar('Gagal', 'Gagal memperbarui status notifikasi.');
    }
  }

  Future<NotificationModel> loadDetail(int id) async {
    if (id <= 0) {
      throw Exception('ID notifikasi tidak valid.');
    }

    final item = await repository.getNotificationDetail(id);

    // Perbarui daftar dan badge setelah detail dibuka.
    await loadNotifications();

    return item;
  }
}
