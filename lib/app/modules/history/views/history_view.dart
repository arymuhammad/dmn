import 'package:dmn_play/app/data/models/watch_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helpers/app_colors.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.selectedTab.value == 0) {
                  return _buildHistory();
                }

                return _buildMyList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'history'.tr.capitalizeFirst ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'continue where you left off'.tr.capitalizeFirst ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),

          // SEARCH
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .07)),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: search nanti
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Obx(() {
      final selected = controller.selectedTab.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Row(
            children: [
              _buildTab(
                index: 0,
                title: 'history',
                icon: Icons.history_rounded,
                selected: selected == 0,
              ),

              _buildTab(
                index: 1,
                title: 'my list',
                icon: Icons.bookmark_rounded,
                selected: selected == 1,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTab({
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? AppColors.contentColorYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.black : Colors.white38,
              ),

              const SizedBox(width: 7),

              Text(
                title.tr.capitalize ?? '',
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white54,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Widget _buildHistory() {
    return Obx(() {
      if (controller.isLoading.value && controller.histories.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.contentColorYellow),
        );
      }

      if (controller.histories.isEmpty) {
        return _buildEmptyState(
          icon: Icons.history_rounded,
          title: 'no viewing history yet',
          description:
              'the series or episode you are watching will appear here',
        );
      }

      return RefreshIndicator(
        color: AppColors.contentColorYellow,
        backgroundColor: const Color(0xFF181818),
        onRefresh: controller.refreshHistory,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          itemCount: controller.histories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = controller.histories[index];

            return _buildHistoryItem(item);
          },
        ),
      );
    });
  }

  // ============================================================
  // HISTORY ITEM
  // ============================================================

  Widget _buildHistoryItem(WatchHistoryModel item) {
    return GestureDetector(
      onTap: () {
        controller.playHistory(item);
      },
      child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ======================================================
            // POSTER
            // ======================================================
            SizedBox(
              width: 82,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFF1D1D1D),
                        child: const Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                        ),
                      );
                    },
                  ),

                  // DARK GRADIENT
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: .35),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // CONTENT
            // ======================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      item.movieTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // EPISODE
                    Text(
                      'Episode ${item.episodeNumber}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // EPISODE
                    Text(
                      item.synopsis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // PROGRESS
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              value: _progress(item),
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.contentColorYellow,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 9),

                        Text(
                          '${(_progress(item) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // PLAY BUTTON
            // ======================================================
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.contentColorYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _progress(WatchHistoryModel item) {
    final watched = item.watchedSeconds;
    final duration = item.duration;

    if (duration <= 0) {
      return 0;
    }

    return (watched / duration).clamp(0.0, 1.0);
  }

  // ============================================================
  // MY LIST
  // ============================================================

  Widget _buildMyList() {
    // Sementara karena endpoint My List belum dibuat.
    //
    // Nanti:
    //
    // controller.myList
    //
    // tinggal menggantikan empty state ini.

    return _buildEmptyState(
      icon: Icons.bookmark_border_rounded,
      title: 'my list is still empty',
      description:
          "save your favorite series so they're easy to find and watch later",
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.contentColorYellow.withValues(alpha: .08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.contentColorYellow.withValues(alpha: .12),
                ),
              ),
              child: Icon(icon, size: 36, color: AppColors.contentColorYellow),
            ),

            const SizedBox(height: 22),

            Text(
              title.tr.capitalizeFirst ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description.tr.capitalizeFirst??'',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MY LIST GRID
  // ============================================================

  Widget _buildMyListGrid(List items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: .62,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(item.poster, fit: BoxFit.cover),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 22, 9, 9),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.contentColorYellow,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
