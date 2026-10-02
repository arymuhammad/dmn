import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mix_episode_model.dart';
import '../../../../data/services/api_config.dart';
import '../../../account/controllers/account_controller.dart';
import '../../../account/views/widget/vip_upgrade_view.dart';
import '../../../player/bindings/player_binding.dart';
import '../../../player/views/player_view.dart';
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

  // ============
  // OPEN PLAYER
  // ============

  Future<void> _openPlayer() async {
    final player = controller.getPlayer(index);
    final videoController = controller.getVideoController(index);

    if (player == null || videoController == null) {
      return;
    }

    // ========================================================
    // SIMPAN POSISI TERAKHIR
    // ========================================================

    final resumePosition = player.state.position;

    // ========================================================
    // PASTIKAN PLAY
    // ========================================================

    if (!player.state.playing) {
      await player.play();
    }

    // ========================================================
    // OPEN PLAYER VIEW
    // ========================================================

    await Get.to(
      () => const PlayerView(),
      binding: PlayerBinding(),
      arguments: {
        // ======================================================
        // MODE MIX
        // ======================================================
        'fromMix': true,

        // ======================================================
        // REUSE PLAYER
        // ======================================================
        'player': player,
        'videoController': videoController,

        // ======================================================
        // EPISODE
        // ======================================================
        'episodeId': episode.id,
        'movieId': episode.movieId,
        'title': episode.title,
        'seriesTitle': episode.seriesTitle,
        'episodeNumber': episode.episodeNumber,

        'videoUrl': episode.videoUrl,
        'synopsis': episode.synopsis,
        'cast': episode.cast,
        'poster': episode.thumbnail,
        'description': episode.description,

        'duration': episode.duration,
        'views': episode.views,
        'isVip': episode.isVip,
        'releaseDate': episode.releaseDate,

        // ======================================================
        // SUBTITLE
        // ======================================================
        'subtitles': episode.subtitles,

        // ======================================================
        // QUALITY
        // ======================================================
        'qualities': episode.qualities,

        // ======================================================
        // POSISI
        // ======================================================
        'resumePosition': resumePosition,

        // ======================================================
        // VIP FULL
        // ======================================================
        'playFull': episode.isVip == 1,

        'fullUrl':
            episode.isVip == 1 && episode.videoUrl.isNotEmpty
                ? ApiConfig.baseUrl + episode.videoUrl
                : '',

        'mixIndex': index,
      },
      transition: Transition.noTransition,
      duration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ==========
        // VIDEO
        // ==========
        MixVideoPlayer(controller: controller, index: index),

        // ==========
        // GRADIENT
        // ==========
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

        // ==========
        // INFORMATION
        // ==========
        Positioned(left: 16, right: 16, bottom: 24, child: _buildInformation()),
      ],
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==========
        // SERIES TITLE
        // ==========
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

        // ==========
        // SYNOPSIS
        // ==========
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

        // ==========
        // EPISODE + TONTON SEKARANG
        // ==========
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

            // ========================================================
            // VIP
            // ========================================================
            if (episode.isVip == 1) ...[
              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 14),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final auth = Get.find<AccountController>();

                // ========================================================
                // VIP CHECK
                // ========================================================

                if (episode.isVip == 1 && !auth.isVip.value) {
                  Get.generalDialog(
                    barrierDismissible: true,
                    barrierLabel: "VIP",
                    barrierColor: Colors.black54,
                    pageBuilder: (_, __, ___) => const VipUpgradeView(),
                  );

                  return;
                }

                // ========================================================
                // OPEN PLAYER
                // ========================================================

                await _openPlayer();
              },
              child: const Text(
                'Tonton Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
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
