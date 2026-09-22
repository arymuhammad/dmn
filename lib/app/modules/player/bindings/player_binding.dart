import 'package:get/get.dart';

import '../../../data/repositories/history_repository.dart';
import '../../../data/services/api_client.dart';
import '../controllers/player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(Get.find<ApiClient>()),
    );
    Get.lazyPut<PlayerController>(() => PlayerController());
  }
}
