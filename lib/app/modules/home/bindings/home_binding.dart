import 'package:get/get.dart';

import '../../movie_banner/controllers/movie_banner_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut(() => MovieBannerController());
  }
}
