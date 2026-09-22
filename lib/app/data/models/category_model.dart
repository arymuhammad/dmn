import 'movie_model.dart';
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final List<MovieModel> movies;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.movies,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      movies:
          (json["movies"] as List? ?? [])
              .map((e) => MovieModel.fromJson(e))
              .toList(),
    );
  }

  /// TAMBAHAN
  factory CategoryModel.fromMovieJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      name: json["name"] ?? "",
      slug: "",
      movies: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "movies": movies.map((e) => e.toJson()).toList(),
    };
  }
}
