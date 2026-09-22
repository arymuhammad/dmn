import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../data/services/storage_service.dart';

class SessionService extends GetxService {
  StreamSubscription<RemoteMessage>? _messageSubscription;

  Future<SessionService> init() async {
    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);

    return this;
  }

  void _handleMessage(RemoteMessage message) {
    final type = message.data['type'];

    if (type == 'USER_SUSPENDED') {
      final reason =
          message.data['reason']?.toString() ??
          'akun anda telah disuspend.'.tr.capitalizeFirst ??
          '';

      handleSuspended(reason);
    }
  }

  Future<void> handleSuspended(String reason) async {
    await StorageService.removeToken();

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF161616),
          title: Text(
            'akun disuspend'.tr.capitalize ?? '',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(reason, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();

                Get.offAllNamed(Routes.LOGIN);
              },
              child: Text('ok'.tr.toUpperCase()),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }
}
