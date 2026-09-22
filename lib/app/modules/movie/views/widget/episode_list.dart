import 'package:dmn_play/app/data/helpers/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/movie_model.dart';
import '../../../account/controllers/account_controller.dart';
import '../../../player/bindings/player_binding.dart';
import '../../../player/views/player_view.dart';
import '../../../account/views/widget/vip_upgrade_view.dart';
import '../../controllers/movie_controller.dart';

class EpisodeList extends GetView<MovieController> {
  final MovieModel movie;
  EpisodeList({super.key, required this.movie});
  final auth = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Episodes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...controller.episodes.map((episode) {
            return Card(
              color: const Color(0xff1f1f1f),

              child: ListTile(
                leading: SizedBox(
                  width: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(movie.poster, fit: BoxFit.cover),
                      Container(color: Colors.black26),
                      const Center(
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.play_arrow, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                title: Text(
                  'Eps ${episode.episodeNumber} | ${episode.title.capitalize ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

                subtitle: Text(
                  "${formatDuration(episode.duration)} min",
                  style: const TextStyle(color: Colors.white54),
                ),

                trailing:
                    episode.isVip
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.lock, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              "VIP",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                        : const SizedBox(),
                onTap: () {
                  if (episode.isVip && !auth.isVip.value) {
                    // Get.back();

                    // epsisode.playPause();

                    Get.generalDialog(
                      barrierDismissible: true,
                      barrierLabel: "VIP",
                      barrierColor: Colors.black54,
                      pageBuilder: (_, __, ___) => const VipUpgradeView(),
                    );

                    return;
                  }

                  Get.to(
                    () => const PlayerView(),
                    binding: PlayerBinding(),
                    arguments: {
                      "episode": episode,
                      "title": episode.title,
                      "episodes": controller.episodes,
                      "movie": movie,
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
