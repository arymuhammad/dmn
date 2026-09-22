import 'package:get/get.dart';

import '../../../data/repositories/movie_repository.dart';
import '../../../data/services/api_client.dart';
import '../controllers/movie_controller.dart';

class MovieBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieRepository>(() => MovieRepository(Get.find<ApiClient>()));
    Get.lazyPut<MovieController>(
      () => MovieController(Get.find<MovieRepository>()),
    );
  }
}
