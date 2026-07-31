import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/movie_banner_controller.dart';
import 'widget/banner_item.dart';

class MovieBannerView extends StatelessWidget {
  MovieBannerView({super.key, required this.tag}) {
    if (!Get.isRegistered<MovieBannerController>(tag: tag)) {
      Get.put(MovieBannerController(), tag: tag);
    }
  }
  final String tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MovieBannerController>(tag: tag);
    return Obx(() {
      if (c.isLoading.value) {
        return const SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return SizedBox(
        height: 260,
        child: Stack(
          children: [
            PageView.builder(
              controller: c.pageController,
              itemCount: c.banners.length,
              onPageChanged: c.onPageChanged,
              itemBuilder: (_, index) {
                return BannerItem(
                  index: index,
                  item: c.banners[index],
                  controller: c,
                );
              },
            ),

            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(c.banners.length, (i) {
                    final active = i == c.currentIndex.value;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white30,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
