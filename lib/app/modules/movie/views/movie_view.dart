import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dmn_play/app/data/helpers/platform_loading.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../data/helpers/toast.dart';
import 'widget/episode_list.dart';
import 'widget/detail_banner.dart';
import '../controllers/movie_controller.dart';
import 'widget/movie_info.dart';
import 'widget/recomended_section.dart';

class MovieView extends GetView<MovieController> {
  const MovieView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.loading.value && controller.movie.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final movie = controller.movie.value;

        if (movie == null) {
          return  Center(
            child: Text(
              "movie tidak ditemukan".tr,
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return CustomMaterialIndicator(
          onRefresh: () async {
            try {
              await controller.load(
                Get.arguments,
                isRefresh: true,
              ); // sesuaikan dengan method milikmu
              showToast("page refreshed".tr);
            } catch (e) {
              showToast("failed to refresh".tr);
            }
          },
          backgroundColor: Colors.black,
          indicatorBuilder: (context, indicatorController) {
            return Padding(
              padding: const EdgeInsets.all(6),
              child: platformLoading(),
            );
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: DetailBanner(movie: movie)),

              SliverToBoxAdapter(child: MovieInfo(movie: movie)),

              SliverToBoxAdapter(child: EpisodeList(movie: movie)),

              SliverToBoxAdapter(child: RecommendedSection()),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      }),
    );
  }
}
