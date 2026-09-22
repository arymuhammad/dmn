// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../episode/views/widget/episode_list.dart';
// import '../../movie/views/widget/movie_info.dart';
// import '../../movie_banner/views/widget/detail_banner.dart';
// import '../controllers/movie_detail_controller.dart';
// import '../../movie/views/widget/recomended_section.dart';

// class MovieDetailView extends GetView<MovieDetailController> {
//   const MovieDetailView({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Obx(() {
//         if (controller.loading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final movie = controller.movie.value;

//         if (movie == null) {
//           return const Center(
//             child: Text(
//               "Movie tidak ditemukan",
//               style: TextStyle(color: Colors.white),
//             ),
//           );
//         }

//         return CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(child: DetailBanner(movie: movie)),

//             SliverToBoxAdapter(child: MovieInfo(movie: movie)),

//             SliverToBoxAdapter(child: EpisodeList(movie:movie)),

//             SliverToBoxAdapter(child: RecommendedSection()),

//             const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
//           ],
//         );
//       }),
//     );
//   }
// }
