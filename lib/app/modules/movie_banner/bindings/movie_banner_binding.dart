import 'package:dmn_play/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/movie_banner_controller.dart';

class MovieBannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieBannerController>(
      () => MovieBannerController(Get.find<HomeController>()),
    );
  }
}
