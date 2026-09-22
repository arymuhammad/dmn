import 'package:get/get.dart';

import '../../../data/models/episode_model.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';

class MovieDetailController extends GetxController {
  final MovieRepository repository;

  MovieDetailController(this.repository);

  final loading = true.obs;

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

  Future<void> load(int id) async {
    try {
      loading(true);

      final data = await repository.detail(id);

      movie.value = data.movie;

      episodes.assignAll(data.episodes);

      recommended.assignAll(data.recommended);
    } catch (e) {
      // print("Detail error: $e");
    } finally {
      loading(false);
    }
  }
}
