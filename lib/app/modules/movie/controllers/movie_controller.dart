import 'package:get/get.dart';

import '../../../data/models/episode_model.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';

class MovieController extends GetxController {
  RxBool expanded = false.obs;

  final MovieRepository repository;

  MovieController(this.repository);

  final loading = true.obs;
  final refreshing = true.obs;

  final movie = Rxn<MovieModel>();

  final episodes = <EpisodeModel>[].obs;

  final recommended = <MovieModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    final id = Get.arguments;

    if (id != null) {
      load(id);
    } else {
      loading(false);
    }
  }

  Future<void> load(int id, {bool isRefresh = false}) async {
    if (isRefresh) {
      refreshing.value = true;
    } else {
      loading.value = true;
    }

    try {
      loading(true);

      final data = await repository.detail(id);

      movie.value = data.movie;

      episodes.assignAll(data.episodes);

      recommended.assignAll(data.recommended);
    } catch (e) {
      // print(e);
      // print(s);
      rethrow;
    } finally {
      if (isRefresh) {
        refreshing.value = false;
      } else {
        loading.value = false;
      }
    }
  }
}
