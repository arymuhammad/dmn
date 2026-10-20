import '../models/notification_model.dart';
import '../services/api_client.dart';

class NotificationsRepository {
  final ApiClient api;

  NotificationsRepository(this.api);

  Future<List<NotificationModel>> getNotifications() async {
    final res = await api.get('/notifications');
    final data = res.data['data'];

    if (data is! List) return [];

    return data
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markAsRead(int id) async {
    await api.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await api.post('/notifications/read-all');
  }

  Future<int> getUnreadCount() async {
    final res = await api.get('/notifications/unread-count');
    final data = res.data['data'];

    if (data is Map) {
      return int.tryParse('${data['unread_count']}') ?? 0;
    }

    return 0;
  }

  Future<NotificationModel> getNotificationDetail(int id) async {
    final res = await api.get('/notifications/$id');
    final data = res.data['data'];

    if (data is! Map) {
      throw Exception('Format detail notifikasi tidak valid.');
    }

    return NotificationModel.fromJson(Map<String, dynamic>.from(data));
  }
}
