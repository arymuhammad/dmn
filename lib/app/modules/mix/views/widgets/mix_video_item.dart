import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mix_episode_model.dart';
import '../../controllers/mix_controller.dart';
import 'mix_video_player.dart';

class MixVideoItem extends StatelessWidget {
  final MixEpisodeModel episode;
  final MixController controller;
  final int index;

  const MixVideoItem({
    super.key,
    required this.episode,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ========================================================
        // VIDEO
        // ========================================================
        MixVideoPlayer(controller: controller, index: index),

        // ========================================================
        // GRADIENT
        // ========================================================
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 0.72, 1.0],
                  colors: [Colors.transparent, Colors.black26, Colors.black87],
                ),
              ),
            ),
          ),
        ),

        // ========================================================
        // INFORMATION
        // ========================================================
        Positioned(left: 16, right: 16, bottom: 24, child: _buildInformation()),
      ],
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ========================================================
        // SERIES TITLE
        // ========================================================
        Text(
          episode.seriesTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        // ========================================================
        // SYNOPSIS
        // ========================================================
        Obx(() {
          final expanded = controller.isSynopsisExpanded(episode.id);

          return AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _collapsedSynopsis(),
            secondChild: _expandedSynopsis(),
          );
        }),

        const SizedBox(height: 12),

        // ========================================================
        // EPISODE
        // ========================================================
        Row(
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white70,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              'Episode ${episode.episodeNumber} / ${episode.totalEpisodes}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _collapsedSynopsis() {
    return Row(
      key: const ValueKey('collapsed'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            episode.synopsis,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(width: 6),

        GestureDetector(
          onTap: () {
            controller.toggleSynopsis(episode.id);
          },
          child: const Text(
            'Selengkapnya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _expandedSynopsis() {
    return GestureDetector(
      key: const ValueKey('expanded'),
      onTap: () {
        controller.toggleSynopsis(episode.id);
      },
      child: Text(
        episode.synopsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
