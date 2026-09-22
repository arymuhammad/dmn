import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/device_service.dart';
import '../../../data/services/google_auth_service.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => Dio(BaseOptions(baseUrl: "http://103.156.15.61/dmn/api/")),
    );

    Get.lazyPut(() => ApiClient(Get.find()));

    Get.lazyPut(() => GoogleAuthService());
    // Get.lazyPut(() => FacebookAuthService());

    Get.lazyPut(
      () => AuthRepository(
        api: Get.find(),
        google: Get.find(),
        deviceService: Get.find<DeviceService>(),
        // facebook: Get.find()
        // storage: Get.find(),
      ),
    );
  }
}
