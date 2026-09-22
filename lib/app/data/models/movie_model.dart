import 'category_model.dart';

class MovieModel {
  final int id;
  final String title;
  final String releaseYear;
  final String type;
  final String synopsis;
  final String cast;
  final String poster;
  final String genre;
  final String totalViews;
  // TAMBAHAN
  final List<CategoryModel> categories;

  MovieModel({
    required this.id,
    required this.title,
    required this.releaseYear,
    required this.type,
    required this.synopsis,
    required this.cast,
    required this.poster,
    required this.genre,
    required this.totalViews,
    // TAMBAHAN
    this.categories = const [],
  });

  static const imageBase = "http://103.156.15.61/dmn/uploads/posters/";

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      releaseYear: json["release_year"] ?? "",
      type: json["type"] ?? "",
      synopsis: json["synopsis"] ?? "",
      cast: json["cast"] ?? "",
      poster: imageBase + (json["poster"] ?? ""),
      genre:
          json["category_name"] ??
          (((json["categories"] ?? json["genres"]) as List? ?? [])
              .map((e) => e["name"])
              .join(", ")),
      totalViews: json["total_views"] ?? "",

      // TAMBAHAN
      categories:
          ((json["categories"] ?? json["genres"]) as List? ?? [])
              .map((e) => CategoryModel.fromMovieJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "release_year": releaseYear,
      "type": type,
      "synopsis": synopsis,
      "poster": poster,
      "category_name": genre,
      "total_views": totalViews,

      // TAMBAHAN
      "categories": categories.map((e) => e.toJson()).toList(),
    };
  }
}
