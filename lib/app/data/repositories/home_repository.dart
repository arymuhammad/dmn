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
}
