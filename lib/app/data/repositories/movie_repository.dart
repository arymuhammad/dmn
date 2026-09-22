import 'package:dmn_play/app/data/models/movie_model.dart';

import '../models/movie_detail_model.dart';
import '../services/api_client.dart';


class MovieRepository {
  final ApiClient api;

  MovieRepository(this.api);

  /// Detail series + episode + recommendation
  Future<MovieDetailModel> detail(int id) async {
    final res = await api.get("movie/detail/$id");
    
// print(res.data);
// print(res.data.runtimeType);
    return MovieDetailModel.fromJson(res.data["data"]);
  }

  /// Semua movie berdasarkan kategori
  Future<List<MovieModel>> byCategory(int categoryId) async {
    final response = await api.get("movie/category/$categoryId");

    return (response.data["data"] as List)
        .map((e) => MovieModel.fromJson(e))
        .toList();
  }

  /// Search
  Future<List<MovieModel>> search(String keyword) async {
    final response = await api.get(
      "movie/search?keyword=${Uri.encodeComponent(keyword)}",
    );

    return (response.data["data"] as List)
        .map((e) => MovieModel.fromJson(e))
        .toList();
  }
}