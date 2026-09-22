import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/views/widget/section_movie_horizontal.dart';
import '../../controllers/movie_controller.dart';

class RecommendedSection extends GetView<MovieController> {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionMovieHorizontal(
      title: "You May Also Like",
      movies: controller.recommended,
    );
  }
}
