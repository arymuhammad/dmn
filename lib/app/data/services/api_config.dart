class ApiConfig {
  // static const String baseUrl = "http://103.156.15.61/dmn/"; // Dev API
  static const String baseUrl = "https://dmnplay.co.id/"; // Prod API
  static const apiUrl = "${baseUrl}api/v1/";
  static const String posterUrl = "${baseUrl}uploads/posters/";
  static const String backdropUrl = "${baseUrl}uploads/backdrops/";
  static const String subtitleUrl = "${baseUrl}uploads/subtitles/";

  // Hanya video/HLS dari Bunny CDN
  static const String cdnUrl = "https://dmn-play.b-cdn.net/";
  static const String hlsUrl = "${cdnUrl}movies/";
}
