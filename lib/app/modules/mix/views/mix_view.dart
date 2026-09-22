import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/mix_controller.dart';
import 'widgets/mix_video_item.dart';

class MixView extends GetView<MixController> {
  const MixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // ======================================================
        // BELUM ADA EPISODE
        // ======================================================

        if (controller.episodes.isEmpty) {
          if (controller.loading.value) {
            return const ColoredBox(
              color: Colors.black,
            );
          }

          return const Center(
            child: Text(
              'Belum ada video tersedia',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          );
        }

        // ======================================================
        // EPISODE SUDAH ADA
        // ======================================================

        return _buildPageView();
      }),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      scrollDirection: Axis.vertical,
      itemCount: controller.episodes.length,
      onPageChanged: controller.onPageChanged,
      itemBuilder: (context, index) {
        final episode = controller.episodes[index];

        return MixVideoItem(
          key: ValueKey(episode.id),
          episode: episode,
          controller: controller,
          index: index,
        );
      },
    );
  }
}