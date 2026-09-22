class MixEpisodeModel {
  final int id;
  final int movieId;
  final String seriesTitle;
  final int episodeNumber;
  final int totalEpisodes;
  final String title;
  final String synopsis;
  final String thumbnail;
  final String videoUrl;
  final String createdAt;

  const MixEpisodeModel({
    required this.id,
    required this.movieId,
    required this.seriesTitle,
    required this.episodeNumber,
    required this.totalEpisodes,
    required this.title,
    required this.synopsis,
    required this.thumbnail,
    required this.videoUrl,
    required this.createdAt,
  });

  factory MixEpisodeModel.fromJson(Map<String, dynamic> json) {
    return MixEpisodeModel(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,

      movieId: int.tryParse(
            json['movie_id']?.toString() ?? '',
          ) ??
          0,

      seriesTitle: json['series_title']?.toString() ?? '',

      episodeNumber: int.tryParse(
            json['episode_number']?.toString() ?? '',
          ) ??
          0,

      totalEpisodes: int.tryParse(
            json['total_episodes']?.toString() ?? '',
          ) ??
          0,

      title: json['title']?.toString() ?? '',

      synopsis: json['synopsis']?.toString() ?? '',

      thumbnail: json['thumbnail']?.toString() ?? '',

      videoUrl: json['video_url']?.toString() ?? '',

      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'series_title': seriesTitle,
      'episode_number': episodeNumber,
      'total_episodes': totalEpisodes,
      'title': title,
      'synopsis': synopsis,
      'thumbnail': thumbnail,
      'video_url': videoUrl,
      'created_at': createdAt,
    };
  }
}