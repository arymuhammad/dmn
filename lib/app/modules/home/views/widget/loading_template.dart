import 'package:flutter/material.dart';

class VideoCardSkeleton extends StatefulWidget {
  const VideoCardSkeleton({super.key});

  @override
  State<VideoCardSkeleton> createState() => _VideoCardSkeletonState();
}

class _VideoCardSkeletonState extends State<VideoCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF202020)),
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment(
                    -1.5 + (_shimmerController.value * 3),
                    0,
                  ),
                  widthFactor: 0.6,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x002FFFFFF),
                          Color(0x18FFFFFF),
                          Color(0x002FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 20,
                bottom: 24,
                child: _shimmerBar(width: double.infinity, height: 10),
              ),
              Positioned(
                left: 8,
                right: 45,
                bottom: 9,
                child: _shimmerBar(width: double.infinity, height: 8),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width >= 600 ? 380 : 260,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const _SkeletonShimmer(),
    );
  }
}

class HomeCategorySkeleton extends StatelessWidget {
  const HomeCategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return Container(
            width: 76,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const _SkeletonShimmer(),
          );
        },
      ),
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer();

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.5 + 3 * _animationController.value, 0),
                end: Alignment(-0.5 + 3 * _animationController.value, 0),
                colors: const [
                  Color(0xFF202020),
                  Color(0xFF383838),
                  Color(0xFF202020),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
