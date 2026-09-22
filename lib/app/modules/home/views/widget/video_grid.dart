import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/movie_model.dart';
import '../../../../routes/app_pages.dart';

class VideoGrid extends StatelessWidget {
  final List<MovieModel> items;

  const VideoGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: const _EmptyMovieState(),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .65,
        ),
        itemBuilder: (_, index) {
          return VideoCard(movie: items[index]);
        },
      ),
    );
  }

  static Widget sliver(List<MovieModel> items) {
    if (items.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        sliver: const SliverToBoxAdapter(child: _EmptyMovieState()),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          return VideoCard(movie: items[index]);
        }, childCount: items.length),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .65,
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final MovieModel movie;

  const VideoCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.MOVIE, arguments: movie.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Poster
            Image.network(
              movie.poster,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey.shade900,
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white30,
                    size: 40,
                  ),
                );
              },
            ),

            /// Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),

            /// Title
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                movie.title.capitalize ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovieState extends StatelessWidget {
  const _EmptyMovieState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.white24),

          const SizedBox(height: 16),

          Text(
            'Movie belum tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Belum ada movie untuk kategori ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
