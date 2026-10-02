import '../services/api_config.dart';
import 'episode_subtitle.dart';
import 'quality_model.dart';

class MixEpisodeModel {
  final int id;
  final int movieId;
  final String seriesTitle;
  final int episodeNumber;
  final int totalEpisodes;
  final String title;
  final String synopsis;
  final List<String> cast;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final String previewUrl;
  final int duration;
  final int views;
  final int isVip;
  final String releaseDate;
  final String createdAt;
  final List<QualityModel> qualities;
  final List<EpisodeSubtitle> subtitles;

  MixEpisodeModel({
    required this.id,
    required this.movieId,
    required this.seriesTitle,
    required this.episodeNumber,
    required this.totalEpisodes,
    required this.title,
    required this.synopsis,
    required this.cast,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.previewUrl,
    required this.duration,
    required this.views,
    required this.isVip,
    required this.releaseDate,
    required this.createdAt,
    this.qualities = const [],
    this.subtitles = const [],
  });
  factory MixEpisodeModel.fromJson(Map<String, dynamic> json) {
    return MixEpisodeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      movieId: int.tryParse(json['movie_id']?.toString() ?? '') ?? 0,
      seriesTitle: json['series_title']?.toString() ?? '',
      episodeNumber:
          int.tryParse(json['episode_number']?.toString() ?? '') ?? 0,
      totalEpisodes:
          int.tryParse(json['total_episodes']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      synopsis: json['synopsis']?.toString() ?? '',
      cast: json['cast'] != null ? List<String>.from(json['cast']) : [],
      description: json['description']?.toString() ?? '',
      thumbnail: ApiConfig.posterUrl + (json['thumbnail'] ?? ''),
      videoUrl: json['video_url']?.toString() ?? '',
      previewUrl: json['preview_url']?.toString() ?? '',
      duration: int.tryParse(json['duration']?.toString() ?? '') ?? 0,
      views: int.tryParse(json['views']?.toString() ?? '') ?? 0,
      isVip: int.tryParse(json['is_vip']?.toString() ?? '') ?? 0,
      releaseDate: json['release_date']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ??
          '', // ====================================================== // QUALITY // ======================================================
      qualities:
          json['qualities'] is List
              ? (json['qualities'] as List)
                  .map(
                    (x) => QualityModel.fromJson(Map<String, dynamic>.from(x)),
                  )
                  .toList()
              : const [], // ====================================================== // SUBTITLE // ======================================================
      subtitles:
          json['subtitles'] is List
              ? (json['subtitles'] as List)
                  .map(
                    (x) =>
                        EpisodeSubtitle.fromJson(Map<String, dynamic>.from(x)),
                  )
                  .toList()
              : const [],
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
      'description': description,
      'thumbnail': thumbnail,
      'video_url': videoUrl,
      'duration': duration,
      'views': views,
      'is_vip': isVip,
      'release_date': releaseDate,
      'created_at': createdAt,
      'qualities': qualities.map((e) => e.toJson()).toList(),
      'subtitles': subtitles.map((e) => e.toJson()).toList(),
    };
  }
}
