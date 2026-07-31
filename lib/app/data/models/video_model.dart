class VideoModel {
  int id;
  String title;
  String hlsUrl;
  String thumbnail;
  int views;
  int likes;

  VideoModel({
    required this.id,
    required this.title,
    required this.hlsUrl,
    required this.thumbnail,
    required this.views,
    required this.likes,
  });

  factory VideoModel.fromJson(
      Map<String,dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      hlsUrl: json['hls_url'],
      thumbnail: json['thumbnail'],
      views: json['views'],
      likes: json['likes'],
    );
  }
}