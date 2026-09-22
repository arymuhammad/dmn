import 'package:dmn_play/app/modules/player/views/widgets/brightness_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import 'widgets/bottom_controls.dart';
import 'widgets/center_controls.dart';
// import 'widgets/gesture_layer.dart';
import 'widgets/overlay_background.dart';
import 'widgets/player_video.dart';
import 'widgets/seek_overlay.dart';
import 'widgets/seek_animation.dart';
import 'widgets/top_bar.dart';
import 'widgets/volume_overlay.dart';

class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PlayerVideo(controller: controller),

          // Gesture selalu aktif
          // const GestureLayer(),
          const BrightnessOverlay(),

          // Background gelap
          const OverlayBackground(),

          // UI player
          const TopBar(),
          const CenterControls(),
          const BottomControls(),

          // Overlay tambahan
          const SeekAnimation(),
          const VolumeOverlay(),
          const SeekOverlay(),
        ],
      ),
    );
  }
}
