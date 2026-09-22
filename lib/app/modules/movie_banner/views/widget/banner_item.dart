import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../data/models/banner_model.dart';
import '../../controllers/movie_banner_controller.dart';

class BannerItem extends StatelessWidget {
  final int index;
  final BannerModel banner;
  final MovieBannerController controller;

  const BannerItem({
    super.key,
    required this.index,
    required this.banner,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.bannerList.length;

      if (count == 0) {
        return const ColoredBox(color: Colors.black);
      }

      final activeIndex = controller.currentIndex.value % count;

      final active = activeIndex == (index % count);

      return Stack(
        fit: StackFit.expand,
        children: [
          // ========================================================
          // BACKGROUND
          // ========================================================
          if (active && controller.ready.value)
            Video(controller: controller.videoController, fit: BoxFit.cover)
          else
            Image.network(banner.poster, fit: BoxFit.cover),

          // ========================================================
          // POSTER
          // ========================================================
          Positioned(
            right: 20,
            top: 20,
            bottom: 20,
            child: Hero(
              tag: "movie_${banner.id}_$index",
              child: Container(
                width: 170,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 35,
                      spreadRadius: -5,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Image.network(banner.poster, fit: BoxFit.cover),
              ),
            ),
          ),

          // ========================================================
          // GRADIENT
          // ========================================================
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: .95),
                  Colors.black.withValues(alpha: .4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ========================================================
          // INFORMATION
          // ========================================================
          Positioned(
            left: 24,
            right: 120,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title.capitalize ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  banner.releaseYear,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      banner.categories.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 10),

                Text(
                  banner.synopsis.capitalizeFirst ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
