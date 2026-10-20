import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/term_of_use_controller.dart';

class TermOfUseView extends GetView<TermOfUseController> {
  const TermOfUseView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        // foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Term of Use',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gagal memuat Term of Use',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.reloadPage,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            WebViewWidget(controller: controller.webController),
            if (controller.isLoading.value)
              LinearProgressIndicator(
                value:
                    controller.progress.value == 0
                        ? null
                        : controller.progress.value / 100,
                backgroundColor: Colors.white12,
                color: const Color(0xFFFFD54F),
              ),
          ],
        );
      }),
    );
  }
}
