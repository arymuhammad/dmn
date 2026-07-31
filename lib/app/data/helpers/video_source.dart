class VideoSource {
  final String url360;
  final String url720;
  final String url1080;

  final List<String> audioTracks; // dub / original
  final String subtitleUrl;

  VideoSource({
    required this.url360,
    required this.url720,
    required this.url1080,
    required this.audioTracks,
    required this.subtitleUrl,
  });
}