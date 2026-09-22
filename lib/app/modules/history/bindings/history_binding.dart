import 'package:get/get.dart';

import '../../../data/repositories/history_repository.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<HistoryRepository>()),
    );
  }
}
