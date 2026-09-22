// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../controllers/player_controller.dart';

// class BrightnessDialog {
//   static void show(PlayerController controller) {
//     Get.bottomSheet(
//       Container(
//         color: const Color(0xff181818),
//         padding: const EdgeInsets.all(20),
//         child: SafeArea(
//           child: Obx(
//             () => Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.brightness_6,
//                   color: Colors.white,
//                   size: 35,
//                 ),

//                 const SizedBox(height: 20),

//                 Slider(
//                   value: controller.brightness.value,
//                   min: 0,
//                   max: 1,
//                   onChanged: controller.setBrightness,
//                 ),

//                 Text(
//                   "${(controller.brightness.value * 100).round()}%",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }