import 'package:dmn_play/app/modules/navbar/controllers/navbar_controller_controller.dart';
import 'package:get/get.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(() => NavbarController());
  }
}
