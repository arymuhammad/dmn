import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../data/helpers/app_colors.dart';
import '../controllers/movie_banner_controller.dart';
import 'widget/banner_item.dart';

class MovieBannerView extends GetView<MovieBannerController> {
  const MovieBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // ==========================================================
          // BANNER
          // ==========================================================
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: 1000,
            itemBuilder: (_, index) {
              return Obx(() {
                final banners = controller.bannerList;

                if (banners.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.contentColorYellow,
                    ),
                  );
                }

                final bannerIndex = index % banners.length;

                return BannerItem(
                  index: index,
                  banner: banners[bannerIndex],
                  controller: controller,
                );
              });
            },
          ),

          // ==========================================================
          // WATCH
          // ==========================================================
          Positioned(
            right: 24,
            bottom: 35,
            child: Obx(() {
              final banners = controller.bannerList;

              if (banners.isEmpty) {
                return const SizedBox.shrink();
              }

              final index = controller.currentIndex.value % banners.length;

              final banner = banners[index];

              final count = controller.bannerList.length;
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('WATCH: ${banner.title}');
                    },
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                    label: Text(
                      'Watch'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contentColorYellow,
                      foregroundColor: Colors.black,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // SMOOTH PAGE INDICATOR
                  // ==========================================================
                  if (count > 1)
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller.pageController,
                        count: count,
                        effect: JumpingDotEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          spacing: 8,
                          dotColor: Colors.white30,
                          activeDotColor: AppColors.contentColorYellow,
                          verticalOffset: 6,
                          jumpScale: 1,
                          // jumpDistance: 15,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
