import 'package:get/get.dart';

import '../../short/controllers/short_controller.dart';

class NavbarController extends GetxController {
  var currentIndex = 0.obs;

  var showEpisode = false.obs;
  var episodeIndex = 0.obs;
  var currentTab = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    // 🔥 penting: sync video system
    Get.find<ShortController>().onTabChanged(index);
    update(['navbar', 'body']);
  }
}
