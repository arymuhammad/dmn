import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/banner_model.dart';

class MovieBannerController extends GetxController {
  final pageController = PageController();

  final currentIndex = 0.obs;

  Timer? _timer;

  final banners = <BannerModel>[].obs;
  final apiKey = '578b1fd4';
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print("MovieBannerController ${hashCode}");
    loadBanner();
    // startAutoSlide();
  }

  Future<void> loadBanner() async {
    try {
      isLoading.value = true;

      final keywords = ['avengers', 'thor', 'interstellar', 'joker', 'dune'];

      final List<BannerModel> result = [];

      for (final movie in keywords) {
        final response = await http.get(
          Uri.parse('https://www.omdbapi.com/?t=$movie&apikey=$apiKey'),
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);

          if (json['Response'] == 'True') {
            result.add(
              BannerModel(
                image: json['Poster'],
                title: json['Title'],
                subtitle: '${json['Year']} • ${json['Genre']}',
              ),
            );
          }
        }
      }

      banners.assignAll(result);

      if (banners.isNotEmpty) {
        startAutoSlide();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void startAutoSlide() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!pageController.hasClients) return;

      int next = currentIndex.value + 1;

      if (next >= banners.length) {
        next = 0;
      }

      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    print("dispose ${hashCode}");
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
