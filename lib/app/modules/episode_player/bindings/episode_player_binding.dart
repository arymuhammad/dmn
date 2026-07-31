import 'package:get/get.dart';

import '../controllers/episode_player_controller.dart';

class EpisodePlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EpisodePlayerController>(
      () => EpisodePlayerController(),
    );
  }
}
