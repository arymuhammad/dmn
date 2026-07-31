class BannerModel {
  final String image;
  final String title;
  final String subtitle;
  String? genre;

  BannerModel({
    required this.image,
    required this.title,
    required this.subtitle,
    this.genre,
  });

  String get safeImage {
    if (image.isEmpty || image == 'N/A') {
      return 'https://picsum.photos/400/600';
    }
    return image;
  }

  factory BannerModel.fromOmdb(Map<String, dynamic> json) {
    return BannerModel(
      image: json['Poster'] ?? '',
      title: json['Title'] ?? '',
      subtitle: json['Year'] ?? '',
      genre: json['Genre'] ?? '',
    );
  }
}
