import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShortController extends GetxController {
  late PageController pageController;

  final videos = [
    'assets/videos/1.mp4',
    'assets/videos/2.mp4',
    'assets/videos/3.mp4',
    'assets/videos/4.mp4',
  ];

  final currentVideo = 0.obs;
  final isEpisodeMode = false.obs;
  final episodeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // currentVideo.value = 0;
  }

  // void initFirstVideo() {
  //   Future.delayed(const Duration(milliseconds: 50), () {
  //     currentVideo.value = 0;
  //   });
  // }

  void changeVideo(int index) {
    currentVideo.value = index;
    print("CURRENT VIDEO: $index");
  }

  void onTabChanged(int tab) {
    if (tab == 1) {
      // force re-trigger video sync
      Future.delayed(const Duration(milliseconds: 100), () {
        currentVideo.refresh();
      });
    }
  }

  void openEpisode(int index) {
    isEpisodeMode.value = true;
    episodeIndex.value = index;

    // amanin jump AFTER frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }
    });
  }

  void closeEpisode() {
    isEpisodeMode.value = false;
  }
}
