// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../controllers/player_controller.dart';

// class AudioDialog {
//   static void show(PlayerController controller) {
//     Get.bottomSheet(
//       Container(
//         decoration: const BoxDecoration(
//           color: Color(0xff181818),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: SafeArea(
//           child: Obx(
//             () => ListView(
//               shrinkWrap: true,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     "Audio",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//                 for (final audio in controller.audioTracks)
//                   ListTile(
//                     leading: const Icon(Icons.graphic_eq, color: Colors.white),

//                     title: Text(
//                       audio,
//                       style: const TextStyle(color: Colors.white),
//                     ),

//                     trailing:
//                         controller.selectedAudio.value == audio
//                             ? const Icon(Icons.check, color: Colors.red)
//                             : null,

//                     onTap: () {
//                       controller.selectedAudio.value = audio;

//                       /// TODO
//                       /// nanti ganti audio track media_kit

//                       Get.back();
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
