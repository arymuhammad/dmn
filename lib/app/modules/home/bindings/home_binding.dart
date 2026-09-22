import 'package:dmn_play/app/data/repositories/home_repository.dart';
import 'package:get/get.dart';

import '../../../data/repositories/history_repository.dart';
import '../../../data/services/api_client.dart';
import '../../history/controllers/history_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => Get.find<ApiClient>());

    Get.lazyPut<HomeRepository>(() => HomeRepository(Get.find<ApiClient>()));

    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(Get.find<ApiClient>()),
    );

    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeRepository>()),
    );

    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<HistoryRepository>()),
      fenix: true,
    );
  }
}
