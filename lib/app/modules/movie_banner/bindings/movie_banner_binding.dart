import 'package:get/get.dart';

import '../controllers/movie_banner_controller.dart';

class MovieBannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieBannerController>(
      () => MovieBannerController(),
    );
  }
}
