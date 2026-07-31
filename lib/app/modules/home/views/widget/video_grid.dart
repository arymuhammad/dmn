import 'package:dmn_play/app/data/models/banner_model.dart';
import 'package:flutter/material.dart';

class VideoGrid extends StatelessWidget {
  final List<BannerModel> items;

  const VideoGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, index) {
        return VideoCard(movie: items[index]);
      },
    );
  }

  static SliverGrid sliver(List<BannerModel> items) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        return VideoCard(movie: items[index]);
      }, childCount: items.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final BannerModel movie;

  const VideoCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.safeImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Image.network(
                'https://picsum.photos/400/600',
                fit: BoxFit.cover,
              );
            },
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),

          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  movie.genre ?? 'unknown',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    // fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
