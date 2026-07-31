import 'dart:ui';

import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/banner_model.dart';
import '../../controllers/movie_banner_controller.dart';

class BannerItem extends StatelessWidget {
  final int index;
  final BannerModel item;
  final MovieBannerController controller;

  const BannerItem({
    super.key,
    required this.index,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.pageController,
      builder: (_, __) {
        double page = index.toDouble();

        if (controller.pageController.hasClients &&
            controller.pageController.position.hasContentDimensions) {
          page = controller.pageController.page ?? index.toDouble();
        }

        final diff = page - index;

        final opacity = (1 - (diff.abs() * 0.7)).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            /// BACKGROUND
            Image.network(
              item.safeImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey.shade900,
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 50,
                  ),
                );
              },
            ),

            /// BLUR + DARK
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(.25)),
            ),

            /// POSTER
            Positioned(
              right: 20,
              top: 20,
              bottom: 20,
              child: Transform.translate(
                offset: Offset(diff * 80, 0),
                child: Opacity(
                  opacity: opacity,
                  child: Hero(
                    tag: item.title,
                    child: Container(
                      width: 170,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.network(item.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),

            /// GRADIENT
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(.95),
                    Colors.black.withOpacity(.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            /// TITLE
            Positioned(
              left: 24,
              right: 120,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Transform.translate(
                    offset: Offset(diff * 45, 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// SUBTITLE
                  Transform.translate(
                    offset: Offset(diff * 30, 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// BUTTON
                  Transform.translate(
                    offset: Offset(diff * 55, 0),
                    child: Opacity(
                      opacity: opacity,
                      child: FilledButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.contentColorYellow,
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
