import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:dmn_play/app/modules/account/views/widget/vip_upgrade_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../../data/helpers/app_colors.dart';
import '../../../../../data/services/api_config.dart';
import '../../../controllers/player_controller.dart';

class EpisodeDialog {
  static void show(PlayerController controller) {
    final auth = Get.find<AccountController>();
    final eps = Get.find<PlayerController>();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.45,
        decoration: const BoxDecoration(
          color: Color(0xff181818),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const SizedBox(height: 8),

              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,0),
                child: Row(
                  children: [
                    Container(
                      height: 65,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image.network(eps.poster.value, fit: BoxFit.fill),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        eps.title.value.capitalize ?? '',
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const TabBar(
                indicatorColor: AppColors.contentColorYellow,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Episode"),
                  Tab(text: "Synopsis"),
                  Tab(text: "Cast"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    /// ==========================
                    /// Episode
                    /// ==========================
                    ListView.builder(
                      itemCount: controller.episodes.length,
                      itemBuilder: (_, index) {
                        final ep = controller.episodes[index];

                        return Obx(() {
                          final playing = eps.currentEpisodeId.value == ep.id;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  playing
                                      ? AppColors.contentColorYellow
                                          .withValues(alpha: .12)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),

                              leading:
                                  playing
                                      ? const CircleAvatar(
                                        backgroundColor:
                                            AppColors.contentColorYellow,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      )
                                      : CircleAvatar(
                                        backgroundColor: Colors.grey.shade800,
                                        child: Text(
                                          "${ep.episodeNumber}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),

                              title: Text(
                                ep.title.capitalize ?? '',
                                style: TextStyle(
                                  color:
                                      playing
                                          ? AppColors.contentColorYellow
                                          : Colors.white,
                                  fontWeight:
                                      playing
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),

                              subtitle:
                                  ep.isVip
                                      ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "VIP",
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                      : null,

                              trailing:
                                  playing
                                      ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.contentColorYellow,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          "Playing",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      // :
                                      // ep.isVip
                                      // ? const Icon(
                                      //   Icons.workspace_premium,
                                      //   color: Colors.amber,
                                      // )
                                      : null,

                              onTap: () {
                                if (ep.isVip && !auth.isVip.value) {
                                  Get.back();
                                  eps.playPause();

                                  Get.generalDialog(
                                    barrierDismissible: true,
                                    barrierLabel: "VIP",
                                    barrierColor: Colors.black54,
                                    pageBuilder:
                                        (_, __, ___) => const VipUpgradeView(),
                                  );
                                  return;
                                }

                                eps.episode = ep;
                                eps.currentEpisodeId.value = ep.id;

                                controller.player?.open(
                                  Media(ApiConfig.baseUrl + ep.videoUrl),
                                  play: true,
                                );

                                Get.back();
                              },
                            ),
                          );
                        });
                      },
                    ),

                    /// ==========================
                    /// Synopsis
                    /// ==========================
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Obx(
                        () => AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.synopsis.value.capitalizeFirst ?? '',
                                maxLines: eps.expanded.value ? null : 3,
                                overflow:
                                    eps.expanded.value
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),

                              if (controller.synopsis.value.length > 120)
                                TextButton(
                                  onPressed: () {
                                    eps.expanded.value = !eps.expanded.value;
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    eps.expanded.value ? "Less" : "More",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// ==========================
                    /// Cast
                    /// ==========================
                    ListView.builder(
                      key: const PageStorageKey('cast_list'),
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.cast.length,
                      itemBuilder: (_, index) {
                        final actor = controller.cast[index];

                        return ListTile(
                          key: ValueKey(actor),
                          leading: const CircleAvatar(
                            child: Icon(Icons.person, color: Colors.white),
                          ),

                          title: Text(
                            actor.capitalize ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

