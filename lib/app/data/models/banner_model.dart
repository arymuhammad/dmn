import 'category_model.dart';

class BannerModel {
  final int id;
  final String title;
  final String poster;
  final String synopsis;
  final String releaseYear;
  final String categoryName;
  // TAMBAHAN
  final List<CategoryModel> categories;
  final String previewUrl;

  BannerModel({
    required this.id,
    required this.title,
    required this.poster,
    required this.synopsis,
    required this.releaseYear,
    required this.categoryName,
    // TAMBAHAN
    this.categories = const [],
    required this.previewUrl,
  });

  static const imageBase = "http://103.156.15.61/dmn/uploads/posters/";

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final categories =
        (json["categories"] as List? ?? [])
            .map((e) => CategoryModel.fromMovieJson(e))
            .toList();

    return BannerModel(
      id: int.parse(json["id"].toString()),
      title: json["title"] ?? "",
      poster: imageBase + (json["poster"] ?? ""),
      synopsis: json["synopsis"] ?? "",
      releaseYear: json["release_year"] ?? "",
      // Tetap support API lama & baru
      categoryName:
          json["category_name"] ?? categories.map((e) => e.name).join(", "),

      categories: categories,
      previewUrl: json["preview_url"] ?? "",
    );
  }
}
