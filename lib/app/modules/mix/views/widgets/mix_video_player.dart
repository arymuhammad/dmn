import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../controllers/mix_controller.dart';

class MixVideoPlayer extends StatelessWidget {
  final MixController controller;
  final int index;

  const MixVideoPlayer({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MixController>(
      id: 'video_$index',
      builder: (_) {
        final videoController = controller.getVideoController(index);

        if (videoController == null) {
          return const ColoredBox(color: Colors.black);
        }

        return Video(
          controller: videoController,
          fit: BoxFit.cover,
          controls: NoVideoControls,
        );
      },
    );
  }
}
