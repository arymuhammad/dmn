import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/banner_model.dart';
import '../../movie_banner/controllers/movie_banner_controller.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final tabs = [
    'Drama',
    'Romance',
    'Action',
    'Comedy',
    'Horror',
    'Classic',
    'Religious',
  ];
  final apiKey = '578b1fd4';

  final videos = <String, List<BannerModel>>{}.obs;
  final searchKeyword = {
    'Drama': 'Drama',
    'Romance': 'Love',
    'Action': 'Action',
    'Comedy': 'Comedy',
    'Horror': 'Horror',
    'Classic': 'Classic',
    'Religious': 'Religious',
  };

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: tabs.length, vsync: this);
    for (final tab in tabs) {
      Get.put(MovieBannerController(), tag: tab);
    }

    loadMovies();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadMovies() async {
    for (final tab in tabs) {
      await loadCategory(tab);
    }
  }

  Future<void> loadCategory(String tab) async {
    final keyword = searchKeyword[tab];

    final response = await http.get(
      Uri.parse('https://www.omdbapi.com/?s=$keyword&apikey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Response'] == 'True') {
        videos[tab] =
            (data['Search'] as List)
                .map((e) => BannerModel.fromOmdb(e))
                .toList();

        videos.refresh();
      }
    }
  }
}
