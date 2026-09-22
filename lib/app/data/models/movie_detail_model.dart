import 'episode_model.dart';
import 'movie_model.dart';

class MovieDetailModel {
  final MovieModel movie;
  final List<EpisodeModel> episodes;
  final List<MovieModel> recommended;

  MovieDetailModel({
    required this.movie,
    required this.episodes,
    required this.recommended,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      movie: MovieModel.fromJson(json),
      episodes:
          (json["episodes"] as List? ?? [])
              .map((e) => EpisodeModel.fromJson(e))
              .toList(),
      recommended:
          (json["recommended"] as List? ?? [])
              .map((e) => MovieModel.fromJson(e))
              .toList(),
    );
  }
}
