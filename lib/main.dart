import 'package:dmn_play/app/modules/navbar/views/navbar_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/modules/home/controllers/home_controller.dart';
import 'app/routes/app_pages.dart';

void main() {
  Get.put(HomeController());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavbarView(),
      getPages: AppPages.routes,
    ),
  );
}
