import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helpers/platform_loading.dart';
import '../../../../data/helpers/toast.dart';
import '../../../history/views/widget/continue_watching.dart';
import '../../controllers/home_controller.dart';
import 'section_movie_horizontal.dart';
import 'video_grid.dart';

class HomeCategoryTab extends StatelessWidget {
  final HomeController controller;
  final int index;

  const HomeCategoryTab({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return CustomMaterialIndicator(
      onRefresh: () async {
        try {
          await controller.loadHome(isRefresh: true);
          showToast("Home Refreshed".tr);
        } catch (_) {
          showToast("Failed to refresh".tr);
        }
      },

      backgroundColor: Colors.black,

      indicatorBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.all(6),
          child: platformLoading(),
        );
      },

      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        slivers: [
          // ======================================================
          // TRENDING
          // HANYA TAB ALL
          // ======================================================
          if (index == 0)
            SliverToBoxAdapter(
              child: SectionMovieHorizontal(
                title: "trending".tr.capitalize ?? '',
                movies: controller.home.value?.trending ?? [],
              ),
            ),

          // ======================================================
          // CONTINUE WATCHING
          // ======================================================
          if (index == 0) ContinueWatchingView(),

          // ======================================================
          // TITLE
          // ======================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                _getTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ======================================================
          // MOVIES KHUSUS TAB INI
          // ======================================================
          Obx(() {
            final movies = controller.getMoviesForCategory(index);

            return VideoGrid.sliver(movies);
          }),
        ],
      ),
    );
  }

  String _getTitle() {
    if (index == 0) {
      return "Discover".tr.capitalize ?? '';
    }

    if (index >= controller.categories.length) {
      return '';
    }

    return controller.categories[index].name.tr.capitalize ?? '';
  }
}
