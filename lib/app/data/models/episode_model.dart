import 'episode_subtitle.dart';
import 'quality_model.dart';

class EpisodeModel {
  final int id;
  final int movieId;
  final int? seasonId;

  final int episodeNumber;

  final String title;
  final String description;

  final String videoUrl;

  final int duration;
  final int views;

  final DateTime? releaseDate;

  final String status;

  /// true = episode VIP
  final bool isVip;

  /// Tambahan (optional dari API)
  final int progress;
  final bool watched;
  List<QualityModel>? qualities;
  final List<EpisodeSubtitle> subtitles;

  EpisodeModel({
    required this.id,
    required this.movieId,
    this.seasonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.views,
    required this.releaseDate,
    required this.status,
    required this.isVip,
    this.progress = 0,
    this.watched = false,
    this.qualities,
    this.subtitles = const [],
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: int.parse(json["id"].toString()),
      movieId: int.parse(json["movie_id"].toString()),
      seasonId:
          json["season_id"] == null
              ? null
              : int.parse(json["season_id"].toString()),
      episodeNumber: int.parse(json["episode_number"].toString()),
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      videoUrl: json["video_url"] ?? "",
      duration: int.tryParse(json["duration"].toString()) ?? 0,
      views: int.tryParse(json["views"].toString()) ?? 0,
      releaseDate:
          json["release_date"] == null
              ? null
              : DateTime.tryParse(json["release_date"]),
      status: json["status"] ?? "published",
      isVip: json["is_vip"].toString() == "1",
      progress: int.tryParse(json["progress"]?.toString() ?? "0") ?? 0,
      watched: json["watched"].toString() == "1",
      qualities:
          json['qualities'] is List
              ? List<QualityModel>.from(
                (json['qualities'] as List).map(
                  (x) => QualityModel.fromJson(x),
                ),
              )
              : [],
      subtitles:
          json["subtitles"] != null
              ? List<EpisodeSubtitle>.from(
                json["subtitles"].map((x) => EpisodeSubtitle.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "movie_id": movieId,
      "season_id": seasonId,
      "episode_number": episodeNumber,
      "title": title,
      "description": description,
      "video_url": videoUrl,
      "duration": duration,
      "views": views,
      "release_date": releaseDate?.toIso8601String(),
      "status": status,
      "is_vip": isVip ? 1 : 0,
      "progress": progress,
      "watched": watched ? 1 : 0,
    };
  }
}
