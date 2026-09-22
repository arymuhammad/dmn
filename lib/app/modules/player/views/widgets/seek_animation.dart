import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/player_controller.dart';

class SeekAnimation extends GetView<PlayerController> {
  const SeekAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Obx(() {
        return Stack(
          children: [
            /// BACKWARD
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedSlide(
                offset:
                    controller.showBackwardAnimation.value
                        ? Offset.zero
                        : const Offset(-0.15, 0),
                duration: const Duration(milliseconds: 180),
                child: AnimatedOpacity(
                  opacity: controller.showBackwardAnimation.value ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: _SeekIndicator(
                      reverse: true,
                      seconds: controller.backwardSeconds.value,
                    ),
                  ),
                ),
              ),
            ),

            /// FORWARD
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSlide(
                offset:
                    controller.showForwardAnimation.value
                        ? Offset.zero
                        : const Offset(0.15, 0),
                duration: const Duration(milliseconds: 180),
                child: AnimatedOpacity(
                  opacity: controller.showForwardAnimation.value ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: _SeekIndicator(
                      reverse: false,
                      seconds: controller.forwardSeconds.value,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SeekIndicator extends StatelessWidget {
  final bool reverse;
  final int seconds;

  const _SeekIndicator({required this.reverse, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 220 + (i * 120)),
              tween: Tween(begin: 0.3, end: 1),
              builder: (_, value, child) {
                return Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      reverse ? Icons.arrow_left_sharp : Icons.arrow_right_sharp,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                );
              },
            );
          }),
        ),

        const SizedBox(height: 8),

        Text(
          "$seconds seconds",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
