class EpisodeSubtitle {
  final int id;
  final String languageCode;
  final String languageName;
  final String subtitlePath;

  EpisodeSubtitle({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.subtitlePath,
  });

  factory EpisodeSubtitle.fromJson(Map<String, dynamic> json) {
    return EpisodeSubtitle(
      id: int.tryParse(json['id'].toString()) ?? 0,
      languageCode: json['language_code']?.toString() ?? '',
      languageName: json['language_name']?.toString() ?? '',
      subtitlePath: json['subtitle_path']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "language_code": languageCode,
        "language_name": languageName,
        "subtitle_path": subtitlePath,
      };
}