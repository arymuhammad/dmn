import 'package:dmn_play/app/modules/movie_banner/views/movie_banner_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helpers/app_colors.dart';
import '../../../data/helpers/platform_loading.dart';
import '../controllers/home_controller.dart';
import 'widget/appbar.dart';
import 'widget/home_category_tab.dart';

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
          body: Center(child: platformLoading()),
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
                  delegate: BannerTabHeaderDelegate(controller: controller),
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

  BannerTabHeaderDelegate({required this.controller});

  static const double bannerHeight = 260;
  static const double tabBarHeight = 48;

  @override
  double get minExtent => tabBarHeight;

  @override
  double get maxExtent => bannerHeight;

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
        // ==========================================================
        // BANNER
        // ==========================================================
        Positioned.fill(child: const MovieBannerView()),

        // ==========================================================
        // TAB BAR
        //
        // TAB BAR ADA PALING ATAS
        // DAN LANGSUNG DI BAWAH APP BAR
        // ==========================================================
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
                // onTap: controller.onCategoryTap,
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
    return oldDelegate.controller != controller;
  }
}
