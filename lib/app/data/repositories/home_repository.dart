import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/home_model.dart';
import '../models/movie_model.dart';
import '../services/api_client.dart';

class HomeRepository {
  final ApiClient api;

  HomeRepository(this.api);

  Future<HomeModel> home() async {
    try {
      final res = await api.get("home");
      // print(res.data.runtimeType);
      // print(res.data);
      if (res.data is! Map) {
        throw Exception("Invalid response: ${res.data}");
      }

      debugPrint('[HOME] URL      : ${res.realUri}');
      return HomeModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      debugPrint('========== HOME ERROR ==========');
      debugPrint('[HOME] STATUS   : ${e.response?.statusCode}');
      debugPrint('[HOME] URL      : ${e.requestOptions.uri}');
      debugPrint('[HOME] RESPONSE : ${e.response?.data}');
      debugPrint('[HOME] MESSAGE  : ${e.message}');
      debugPrint('================================');

      rethrow;
    }
  }

  Future<List<MovieModel>> category(int categoryId) async {
    try {
      final res = await api.get("movie-category/$categoryId");

      if (res.data is! Map) {
        throw Exception("Invalid response: ${res.data}");
      }

      final data = res.data["data"];

      if (data is! List) {
        throw Exception("Invalid category data: $data");
      }

      return data.map((e) => MovieModel.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('========== CATEGORY ERROR ==========');
      debugPrint('[CATEGORY] ID       : $categoryId');
      debugPrint('[CATEGORY] STATUS   : ${e.response?.statusCode}');
      debugPrint('[CATEGORY] URL      : ${e.requestOptions.uri}');
      debugPrint('[CATEGORY] RESPONSE : ${e.response?.data}');
      debugPrint('[CATEGORY] MESSAGE  : ${e.message}');
      debugPrint('====================================');

      rethrow;
    }
  }

  Future<Map<String, dynamic>> allMovies({int page = 1, int limit = 20}) async {
    final res = await api.get('all-movies?page=$page&limit=$limit');

    if (res.data is! Map) {
      throw Exception('Invalid response: ${res.data}');
    }

    final responseData = res.data['data'];

    if (responseData is! Map) {
      throw Exception('Invalid pagination data: $responseData');
    }

    final items = responseData['items'];

    if (items is! List) {
      throw Exception('Invalid movie list: $items');
    }

    return {
      'items': items.map((e) => MovieModel.fromJson(e)).toList(),
      'page': responseData['page'] ?? page,
      'has_more': responseData['has_more'] == true,
    };
  }
}
