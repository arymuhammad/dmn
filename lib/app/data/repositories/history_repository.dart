import 'package:dio/dio.dart';

import '../models/watch_history_model.dart';
import '../services/api_client.dart';

class HistoryRepository {
  final ApiClient api;

  HistoryRepository(this.api);

  Future<void> updateHistory({
    required int episodeId,
    required int seconds,
    String? subtitleId,
    String? streamId,
  }) async {
    try {
      // final res =
      await api.post(
        "/history/update",
        body: {
          "episode_id": episodeId,
          "seconds": seconds,
          "subtitle_id": subtitleId,
          "stream_id": streamId,
        },
        options: Options(responseType: ResponseType.plain),
      );

      // print(res.data);
    } catch (e) {
      // print(e);
    }
  }

  Future<int> resume(int episodeId) async {
    final res = await api.get("/history/resume/$episodeId");

    return res.data["data"]["seconds"] ?? 0;
  }

  Future<List<WatchHistoryModel>> continueWatching() async {
    final res = await api.get("/history/continueWatching");

    return (res.data["data"] as List)
        .map((e) => WatchHistoryModel.fromJson(e))
        .toList();
  }

  Future<void> addEpisodeView({required int episodeId}) async {
    try {
      // final res =
      await api.post(
        "/episode/view/$episodeId",
        options: Options(responseType: ResponseType.plain),
      );

      // print(res.data);
    } catch (e) {
      // print(e);
    }
  }
}
