import 'package:dmn_play/app/modules/movie_banner/views/movie_banner_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helpers/app_colors.dart';
import '../controllers/home_controller.dart';
import 'widget/appbar.dart';
import 'widget/video_grid.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabs.length,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            // headerSliverBuilder: (_, __) {
            children: [
              const HomeAppBar(),
              TabBar(
                controller: controller.tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelPadding: EdgeInsets.only(right: 50),
                indicatorColor: AppColors.contentColorYellow,
                tabs:
                    controller.tabs
                        .map((e) => Tab(height: 25, text: e))
                        .toList(),
              ),

              // MovieBannerView(),
              Expanded(
                child: Obx(() {
                  return TabBarView(
                    controller: controller.tabController,
                    children:
                        controller.tabs.map((tab) {
                          final movies = controller.videos[tab] ?? [];

                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(child: MovieBannerView( tag: tab,)),

                              const SliverPadding(
                                padding: EdgeInsets.only(top: 20),
                              ),

                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                sliver: VideoGrid.sliver(movies),
                              ),
                            ],
                          );
                        }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),

        // },
      ),
    );
  }
}
