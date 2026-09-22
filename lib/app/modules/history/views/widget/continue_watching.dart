import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/history_controller.dart';

class ContinueWatchingView extends GetView<HistoryController> {
  const ContinueWatchingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.contentColorYellow,
              ),
            ),
          ),
        );
      }

      if (controller.histories.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox());
      }

      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "continue watching".tr.capitalize ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "see all".tr.capitalize ?? '',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.histories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final item = controller.histories[index];

                return SizedBox(
                  width: 105,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await controller.playHistory(item);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(item.poster, fit: BoxFit.cover),

                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Color(0x88000000),
                                  Color(0xEE000000),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${item.progress.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const Center(
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black45,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.movieTitle.capitalize ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  item.episodeTitle.capitalize ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 4,
                              color: Colors.white24,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (item.progress / 100).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Container(color: Colors.red),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 4,
                            right: -28,
                            child: Transform.rotate(
                              angle: 0.785398,
                              child: Container(
                                width: 90,
                                height: 20,
                                alignment: Alignment.center,
                                color: Colors.red.shade700,
                                child: Text(
                                  "EP ${item.episodeNumber}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      );
    });
  }
}
