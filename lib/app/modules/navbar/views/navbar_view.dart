import 'package:dmn_play/app/modules/bookmark/views/bookmark_view.dart';
import 'package:dmn_play/app/modules/episode_player/controllers/episode_player_controller.dart';
import 'package:dmn_play/app/modules/episode_player/views/episode_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../account/views/account_view.dart';
import '../../home/views/home_view.dart';
import '../../short/views/short_view.dart';
import '../controllers/navbar_controller_controller.dart';
import 'widget/modern_bottombar.dart';

class NavbarView extends StatelessWidget {
  NavbarView({super.key});

  final c = Get.put(NavbarController());
  final epC = Get.put(EpisodePlayerController());
  final pages = [
    const HomeView(),
    ShortView(),
    const BookmarkView(),
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            IndexedStack(index: c.currentIndex.value, children: pages),

            // 🔥 EPISODE MODE OVERLAY (FULL CONTROL)
            if (epC.isOpen.value) Positioned.fill(child: EpisodeOverlay()),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () =>
           epC.isOpen.value
                ? const SizedBox() // navbar hilang
                : const ModernBottomBar(),
      ),
    );
  }
}
