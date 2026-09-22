import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class PlayerProgress extends GetView<PlayerController> {
  const PlayerProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          activeTrackColor: AppColors.contentColorYellow,
          // activeTickMarkColor: AppColors.contentColorYellow,
          thumbColor: AppColors.contentColorYellow,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: Slider(
          min: 0,
          max:
              controller.duration.value.inMilliseconds.toDouble() == 0
                  ? 1
                  : controller.duration.value.inMilliseconds.toDouble(),
          value:
              controller.position.value.inMilliseconds
                  .clamp(0, controller.duration.value.inMilliseconds)
                  .toDouble(),
          onChanged: (v) {
            controller.seek(Duration(milliseconds: v.toInt()));
          },
        ),
      );
    });
  }
}
