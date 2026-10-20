import 'package:get/get.dart';

import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/api_client.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsRepository>(
      () => NotificationsRepository(Get.find<ApiClient>()),
    );

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find<NotificationsRepository>()),
    );
  }
}
