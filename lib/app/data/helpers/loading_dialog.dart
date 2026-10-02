import 'dart:io';

import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

loadingDialog(msg, String? msg2) {
  Get.defaultDialog(
    title: '',
    onWillPop: () async {
      return false;
    },
    backgroundColor: const Color(0xFF1E1C1C),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Platform.isAndroid
            ? const CircularProgressIndicator(
              color: AppColors.contentColorYellow,
            )
            : const CupertinoActivityIndicator(),
        const SizedBox(height: 10),
        Text(msg, style: TextStyle(color: AppColors.contentColorWhite)),
        Text(msg2!),
      ],
    ),
    barrierDismissible: false,
  );
}

void closeLoading() {
  while (Get.isDialogOpen ?? false) {
    Get.back();
  }
}
