import 'package:get/get.dart';

import '../controllers/term_of_use_controller.dart';

class TermOfUseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermOfUseController>(
      () => TermOfUseController(),
    );
  }
}
