import 'package:dmn_play/app/modules/movie/controllers/movie_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/movie_model.dart';

class MovieInfo extends StatelessWidget {
  final MovieModel movie;
  final mc = Get.find<MovieController>();
  MovieInfo({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title.capitalize ?? '',
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                movie.releaseYear.toString(),
                style: const TextStyle(color: Colors.green),
              ),

              const SizedBox(width: 10),

              Text(movie.genre, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 15),

          Obx(
            () => AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.synopsis,
                    maxLines: mc.expanded.value ? null : 3,
                    overflow:
                        mc.expanded.value
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),

                  if (movie.synopsis.length > 120)
                    TextButton(
                      onPressed: () {
                        mc.expanded.value = !mc.expanded.value;
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        mc.expanded.value ? "Less" : "More",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
