import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/video_item.dart';
import '../controllers/short_controller.dart';

class ShortView extends GetView<ShortController> {
  ShortView({super.key});
  final cShort = Get.put(ShortController());
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔥 MAIN VIDEO LIST (SELALU ADA)
        PageView.builder(
          controller: cShort.pageController,
          scrollDirection: Axis.vertical,
          itemCount: cShort.videos.length,
          onPageChanged: (index) {
            cShort.changeVideo(index);
          },
          itemBuilder: (context, index) {
            return VideoItem(
              index: index,
              path: cShort.videos[index],
              subtitleUrl: 'id',
            );
          },
        ),

        Positioned(
          left: 16,
          bottom: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sinopsis film. Film ini bercerita tentang ...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        // 🔥 RIGHT ACTIONS (SELALU ADA)
        Positioned(
          right: 16,
          bottom: 50,
          child: Column(
            children: [
              const Icon(Icons.favorite_outline, color: Colors.white, size: 30),
              const SizedBox(height: 20),
              const Icon(
                Icons.bookmark_outline_sharp,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: showSettingPlayer,
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),

        // 🔥 EPISODE MODE OVERLAY (TIDAK MENUTUP TOTAL)
        // if (controller.isEpisodeMode.value)
        //   Positioned.fill(
        //     child: Container(
        //       color: Colors.black.withOpacity(0.6),
        //       child: Column(
        //         children: [
        //           // 🔥 APPBAR BACK
        //           SafeArea(
        //             child: Row(
        //               children: [
        //                 IconButton(
        //                   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //                   onPressed: () {
        //                     controller.closeEpisode();
        //                   },
        //                 ),
        //                 const Text(
        //                   "Episode Player",
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //               ],
        //             ),
        //           ),

        //           const Spacer(),

        //           // optional UI tengah
        //           Text(
        //             "EPISODE ${controller.episodeIndex.value}",
        //             style: const TextStyle(
        //               color: Colors.white,
        //               fontSize: 18,
        //             ),
        //           ),

        //           const Spacer(),
        //         ],
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  void showSettingPlayer() {
    Get.bottomSheet(
      Container(
        height: 260,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.itemsBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            _SettingTile(icon: Icons.subtitles, title: 'Subtitle'),
            const Divider(height: 0, thickness: 0.5, color: Colors.white24),
            _SettingTile(icon: Icons.multitrack_audio_rounded, title: 'Audio'),
            const Divider(height: 0, thickness: 0.5, color: Colors.white24),
            _SettingTile(icon: Icons.high_quality_outlined, title: 'Quality'),
            const Divider(height: 0, thickness: 0.5, color: Colors.white24),
            _SettingTile(icon: Icons.speed_outlined, title: 'Speed'),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {},
    );
  }
}
