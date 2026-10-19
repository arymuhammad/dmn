import 'package:dmn_play/app/modules/movie_banner/views/movie_banner_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helpers/app_colors.dart';
import '../../../data/helpers/platform_loading.dart';
import '../controllers/home_controller.dart';
import 'widget/appbar.dart';
import 'widget/home_category_tab.dart';
import 'widget/loading_template.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final home = controller.home.value;
      final tabController = controller.tabController;

      // ============================================================
      // WAIT UNTIL HOME DATA + TAB CONTROLLER READY
      // ============================================================
      if (home == null || tabController == null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: HomeAppBar()),

                // Placeholder banner
                const SliverToBoxAdapter(child: HomeBannerSkeleton()),

                // Placeholder tab kategori
                const SliverToBoxAdapter(child: HomeCategorySkeleton()),

                // Placeholder grid movie
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const VideoCardSkeleton(),
                      childCount: 12,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: .65,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: NestedScrollView(
            physics: const ClampingScrollPhysics(),

            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // ============================================================
                // APP BAR
                // ============================================================
                const SliverToBoxAdapter(child: HomeAppBar()),

                // ============================================================
                // BANNER + TABBAR OVERLAY
                // ============================================================
                SliverPersistentHeader(
                  pinned: true,
                  delegate: BannerTabHeaderDelegate(
                    controller: controller,
                    screenWidth: MediaQuery.sizeOf(context).width,
                  ),
                ),
              ];
            },

            body: TabBarView(
              controller: controller.tabController,
              children: List.generate(controller.categories.length, (index) {
                return HomeCategoryTab(controller: controller, index: index);
              }),
            ),
          ),
        ),
      );
    });
  }
}

class BannerTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeController controller;
  final double screenWidth;

  BannerTabHeaderDelegate({
    required this.controller,
    required this.screenWidth,
  });

  static const double bannerHeight = 260;
  static const double tabletBannerHeight = 380;
  static const double tabBarHeight = 48;

  double get responsiveBannerHeight =>
      screenWidth >= 600 ? tabletBannerHeight : bannerHeight;

  @override
  double get minExtent => tabBarHeight;

  @override
  double get maxExtent => responsiveBannerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / 80).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: MovieBannerView()),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: tabBarHeight,
          child: ClipRect(
            child: Container(
              color:
                  Color.lerp(
                    Colors.black.withValues(alpha: .35),
                    Colors.black,
                    progress,
                  )!,
              child: TabBar(
                controller: controller.tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: AppColors.contentColorYellow,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                tabs:
                    controller.categories
                        .map((e) => Tab(text: e.name.tr))
                        .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant BannerTabHeaderDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.screenWidth != screenWidth;
  }
}

