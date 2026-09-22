import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helpers/app_colors.dart';
import '../../short/controllers/short_controller.dart';

class EpisodePlayerController extends GetxController {
  var isOpen = false.obs;
  var currentEpisode = 0.obs;
  var isSheetOpen = false.obs;
  late List episodes;
  var currentIndex = 0.obs;

  @override
  void onClose() {
    isSheetOpen.value = false;
    super.onClose();
  }

  void open(List data, int index) {
    episodes = data;
    currentEpisode.value = index;
    currentIndex.value = index;
    isOpen.value = true;

    // openSheet();
  }

  void close() {
    isOpen.value = false;
    isSheetOpen.value = false;
  }

  bool get isInEpisode => isOpen.value;

  void openSheet() {
    if (isSheetOpen.value) return;

    isSheetOpen.value = true;

    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Handle drag
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

               TabBar(
                //  dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelPadding: EdgeInsets.only(right: 50),
                indicatorColor: AppColors.contentColorYellow,
                tabs: [
                  Tab(text: 'sinopsis'.tr),
                  Tab(text: 'episodes'.tr),
                  Tab(text: ''),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    /// TAB SINOPSIS
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'sinopsis__2'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),

                    /// TAB EPISODE
                    GetBuilder<ShortController>(
                      builder: (shortC) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: episodes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.5,
                              ),
                          itemBuilder: (context, index) {
                            final isSelected = currentIndex.value == index;

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                currentIndex.value = index;

                                shortC.pageController.jumpToPage(index);

                                shortC.changeVideo(index);

                                Get.back();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.yellow
                                          : Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.yellow
                                            : Colors.white24,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'EP ${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Blank Tab
                    SizedBox.shrink()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      isSheetOpen.value = false;
    });
  }
}
