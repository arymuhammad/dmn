import 'package:dmn_play/app/modules/login/controllers/login_controller.dart';
import 'package:get/get.dart';

import '../data/helpers/currency_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/home_repository.dart';
import '../data/repositories/mix_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/api_client.dart';

import '../data/services/device_service.dart';
import '../data/services/google_auth_service.dart';
import '../data/services/push_notification_service.dart';
import '../data/services/service_api.dart';
import '../data/translations/controller/language_controller.dart';
import '../modules/account/controllers/account_controller.dart';
import '../modules/history/controllers/history_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/mix/controllers/mix_controller.dart';
import '../modules/movie_banner/controllers/movie_banner_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ============================================================
    // SERVICES
    // ============================================================
    Get.put<ApiClient>(ApiClient(ServiceApi.dio), permanent: true);

    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);

    Get.put<DeviceService>(DeviceService(), permanent: true);

    // ============================================================
    // REPOSITORIES
    // ============================================================

    Get.put<AuthRepository>(
      AuthRepository(
        api: Get.find<ApiClient>(),
        google: Get.find<GoogleAuthService>(),
        deviceService: Get.find<DeviceService>(),
        // facebook: Get.find<FacebookAuthService>()
      ),
      permanent: true,
    );

    Get.put<UserRepository>(
      UserRepository(Get.find<ApiClient>(), Get.find<DeviceService>()),
      permanent: true,
    );

    // Push Notification
    Get.put<PushNotificationService>(
      PushNotificationService(
        Get.find<AuthRepository>(),
        Get.find<UserRepository>(),
      ),
      permanent: true,
    );

    Get.put<HomeRepository>(
      HomeRepository(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<HistoryRepository>(
      HistoryRepository(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<MixRepository>(
      MixRepository(Get.find<ApiClient>()),
      permanent: true,
    );

    // ============================================================
    // CONTROLLERS
    // ============================================================

    Get.put<HomeController>(
      HomeController(Get.find<HomeRepository>()),
      permanent: true,
    );

    Get.put<MixController>(
      MixController(Get.find<MixRepository>()),
      permanent: true,
    );
    // Get.lazyPut<MixController>(() => MixController(Get.find<MixRepository>()));

    Get.put<AccountController>(
      AccountController(
        Get.find<AuthRepository>(),
        Get.find<HomeController>(),
        Get.find<UserRepository>(),
      ),
      permanent: true,
    );

    Get.put<LoginController>(
      LoginController(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<MovieBannerController>(
      MovieBannerController(Get.find<HomeController>()),
      permanent: true,
    );

    Get.put<HistoryController>(
      HistoryController(Get.find<HistoryRepository>()),
      permanent: true,
    );

    // ============================================================
    // CURRENCY
    // ============================================================

    Get.put<CurrencyService>(CurrencyService(), permanent: true);

    // ============================================================
    // LANGUAGE
    // ============================================================

    Get.put<LanguageController>(LanguageController(), permanent: true);
  }
}
