import 'dart:async';

import 'package:dmn_play/app/data/repositories/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/account/controllers/account_controller.dart';
import '../../modules/login/views/widgets/suspended_dialog.dart';
import '../repositories/auth_repository.dart';
import '../services/storage_service.dart';

class PushNotificationService {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  PushNotificationService(this.authRepository, this.userRepository);

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenSubscription;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      debugPrint('🔥 FCM SERVICE ALREADY INITIALIZED');
      return;
    }

    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // ============================================================
    // REGISTER TOKEN
    // ============================================================

    final token = await messaging.getToken();

    debugPrint('🔥 FCM TOKEN = $token');

    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }

    _tokenSubscription = messaging.onTokenRefresh.listen(_registerToken);

    // ============================================================
    // FOREGROUND MESSAGE
    // ============================================================

    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);

    debugPrint('🔥 FCM FOREGROUND LISTENER REGISTERED');
  }

  Future<void> _registerToken(String token) async {
    try {
      await userRepository.registerFcmToken(token: token);
    } catch (e) {
      debugPrint('FCM REGISTER ERROR: $e');
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    debugPrint('🔥🔥 FCM FOREGROUND MASUK');
    debugPrint('DATA = ${message.data}');
    debugPrint('NOTIFICATION = ${message.notification}');
    debugPrint('FCM MESSAGE: ${message.data}');

    final type = message.data['type'];

    if (type == 'account_suspended') {
      await _handleAccountSuspended(message);
    }
  }

  Future<void> _handleAccountSuspended(RemoteMessage message) async {
    debugPrint('ACCOUNT SUSPENDED');

    final reason = message.data['reason'] ?? '';

    // ============================================================
    // CLEAR LOGIN STATE
    // ============================================================

    await StorageService.clear();
    await authRepository.google.logout();

    // ============================================================
    // CLEAR ACCOUNT CONTROLLER
    // ============================================================

    if (Get.isRegistered<AccountController>()) {
      Get.find<AccountController>().clearUser();
    }

    // ============================================================
    // GO TO LOGIN
    // ============================================================
    Get.offAllNamed('/login');

    // ============================================================
    // SHOW SUSPENDED DIALOG
    // ============================================================
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.context == null) return;

      Get.dialog(
        SuspendedDialog(
          message: reason.isNotEmpty ? reason : 'Akun Anda telah ditangguhkan.',
        ),
        barrierDismissible: false,
      );
    });
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenSubscription?.cancel();

    _messageSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }
}
