import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/mix_episode_model.dart';
import '../services/api_client.dart';

class MixRepository {
  final ApiClient api;

  MixRepository(this.api);

  Future<List<MixEpisodeModel>> mix() async {
    try {
      final response = await api.get('mix');

      final data = response.data['data'];

      if (data is! List) {
        throw Exception('Invalid MIX response');
      }

      return data
          .map((e) => MixEpisodeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('========== MIX ERROR ==========');
      debugPrint('[MIX] STATUS   : ${e.response?.statusCode}');
      debugPrint('[MIX] URL      : ${e.requestOptions.uri}');
      debugPrint('[MIX] RESPONSE : ${e.response?.data}');
      debugPrint('[MIX] MESSAGE  : ${e.message}');
      debugPrint('================================');

      rethrow;
    }
  }
}
