import 'package:flutter/material.dart';
import '../../../../data/helpers/app_colors.dart';
import '../../../../data/models/movie_model.dart';

class DetailBanner extends StatelessWidget {
  final MovieModel movie;

  const DetailBanner({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
           movie.poster,
            fit: BoxFit.cover,
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black26,
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Spacer(),

                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            // left: 30,
            right: 30,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.contentColorYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(100, 40),
              ),
              onPressed: () {},
              icon: const Icon(Icons.play_circle),
              label: const Text("Play"),
            ),
          )
        ],
      ),
    );
  }
}