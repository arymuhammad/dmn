import 'package:dmn_play/app/data/services/api_config.dart';

import 'episode_model.dart';
import 'episode_subtitle.dart';
import 'quality_model.dart';

class WatchHistoryModel {
  final int id;
  final int userId;
  final int movieId;
  final int episodeId;
  final int? subtitleId;
  final int? streamId;

  final int episodeNumber;
  final int duration;
  final int watchedSeconds;
  final double progress;
  final bool completed;
  final DateTime? lastWatch;

  final String movieTitle;
  final String episodeTitle;
  final String poster;
  final String videoUrl;
  final int views;
  final String description;
  final DateTime? releaseDate;
  final String status;
  final bool isVip;
  final List<EpisodeSubtitle> subtitles;
  final List<QualityModel> qualities;

  final String synopsis;
  final List<String> cast;
  final List<EpisodeModel> episodes;

  WatchHistoryModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.episodeId,

    this.subtitleId,
    this.streamId,

    required this.episodeNumber,
    required this.duration,
    required this.watchedSeconds,
    required this.progress,
    required this.completed,
    required this.lastWatch,
    required this.movieTitle,
    required this.episodeTitle,
    required this.poster,
    required this.videoUrl,

    required this.views,
    required this.description,
    required this.releaseDate,
    required this.status,
    required this.isVip,

    required this.subtitles,
    required this.qualities,

    required this.synopsis,
    required this.cast,
    required this.episodes,
  });

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) {
    return WatchHistoryModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      movieId: int.parse(json['movie_id'].toString()),
      episodeId: int.parse(json['episode_id'].toString()),
      episodeNumber: int.parse(json['episode_number'].toString()),
      duration: int.parse(json['duration'].toString()),
      watchedSeconds: int.parse(json['position'].toString()),
      progress: double.parse(json['progress'].toString()),
      completed: json['completed'].toString() == '1',
      lastWatch:
          json['last_watched_at'] != null
              ? DateTime.tryParse(json['last_watched_at'])
              : null,
      movieTitle: json['movie_title'] ?? '',
      episodeTitle: json['episode_title'] ?? '',
      poster: ApiConfig.posterUrl + (json['poster'] ?? ''),
      videoUrl: json['video_url'] ?? '',

      views: int.tryParse(json['views'].toString()) ?? 0,

      description: json['description'] ?? '',

      releaseDate:
          json['release_date'] != null
              ? DateTime.tryParse(json['release_date'])
              : null,

      status: json['status'] ?? 'published',

      isVip: json['is_vip'].toString() == '1',

      subtitles:
          json["subtitles"] != null
              ? List<EpisodeSubtitle>.from(
                json["subtitles"].map((e) => EpisodeSubtitle.fromJson(e)),
              )
              : [],

      qualities:
          json["qualities"] != null
              ? List<QualityModel>.from(
                json["qualities"].map((e) => QualityModel.fromJson(e)),
              )
              : [],
      subtitleId:
          json["subtitle_id"] != null
              ? int.tryParse(json["subtitle_id"].toString())
              : null,

      streamId:
          json["stream_id"] != null
              ? int.tryParse(json["stream_id"].toString())
              : null,
      synopsis: json["synopsis"] ?? "",

      cast: json["cast"] != null ? List<String>.from(json["cast"]) : [],

      episodes:
          json["episodes"] != null
              ? List<EpisodeModel>.from(
                json["episodes"].map((e) => EpisodeModel.fromJson(e)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'episode_id': episodeId,
      'duration': duration,
      'watched_seconds': watchedSeconds,
      'progress': progress,
      'completed': completed ? 1 : 0,
      'last_watch': lastWatch?.toIso8601String(),
      'movie_title': movieTitle,
      'episode_title': episodeTitle,
      'poster': poster,
      'synopsis': synopsis,
      'cast': cast,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}
