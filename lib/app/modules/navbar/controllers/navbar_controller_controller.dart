import 'package:get/get.dart';

import '../../../data/repositories/mix_repository.dart';
import '../../mix/controllers/mix_controller.dart';

class NavbarController extends GetxController {
  var currentIndex = 0.obs;

  var showEpisode = false.obs;
  var episodeIndex = 0.obs;
  var currentTab = 0.obs;

  static const int homeTab = 0;
  static const int mixTab = 1;
  static const int historyTab = 2;
  static const int accountTab = 3;

  Future<void> changeTab(int index) async {
    if (currentIndex.value == index) {
      return;
    }

    final oldIndex = currentIndex.value;

    // ==========================================================
    // KELUAR DARI MIX
    // ==========================================================

    if (oldIndex == mixTab) {
      if (Get.isRegistered<MixController>()) {
        await Get.find<MixController>().pauseAllVideos();
      }
    }

    // ==========================================================
    // MASUK KE MIX
    // ==========================================================

    if (index == mixTab) {
      if (!Get.isRegistered<MixController>()) {
        Get.put<MixController>(MixController(Get.find<MixRepository>()));
      } else {
        await Get.find<MixController>().resumeCurrentVideo();
      }
    }

    // ==========================================================
    // CHANGE TAB
    // ==========================================================

    currentIndex.value = index;

    update(['navbar', 'body']);
  }
}
