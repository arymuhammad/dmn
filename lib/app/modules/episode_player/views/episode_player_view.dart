import 'package:dmn_play/app/modules/episode_player/controllers/episode_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../short/views/short_view.dart';

class EpisodeOverlay extends StatelessWidget {
  EpisodeOverlay({super.key});

  final nav = Get.find<EpisodePlayerController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ❌ HAPUS INI
          ShortView(),

          // HEADER
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: nav.close,
                ),
                const Text("Episodes", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
