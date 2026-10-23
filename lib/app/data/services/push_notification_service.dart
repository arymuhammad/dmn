import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dmn_play/app/data/repositories/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/account/controllers/account_controller.dart';
import '../../modules/login/views/widgets/suspended_dialog.dart';
import '../repositories/auth_repository.dart';
import '../services/storage_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  PushNotificationService(this.authRepository, this.userRepository);

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenSubscription;

  bool _initialized = false;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _foregroundChannel =
      AndroidNotificationChannel(
        'dmnplay_foreground',
        'DMN Play',
        description: 'Notifikasi resmi dari DMN Play',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  Future<void> init() async {
    debugPrint('[FCM DEBUG] PushNotificationService.init() DIPANGGIL');
    final messaging = FirebaseMessaging.instance;

    if (_initialized) {
      debugPrint('🔥 FCM SERVICE ALREADY INITIALIZED — REGISTER TOKEN AGAIN');

      // Service sudah aktif, tetapi akun bisa saja sudah berganti.
      // Ambil token dan daftarkan untuk akun yang sekarang login.
      try {
        final token = await messaging.getToken();

        if (token != null && token.isNotEmpty) {
          await _registerToken(token);
        }
      } catch (e, stackTrace) {
        debugPrint('[FCM] Re-register ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      return;
    }

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // iOS menampilkan notifikasi langsung saat foreground.
    // Android menggunakan flutter_local_notifications.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Inisialisasi notifikasi lokal.
    await _initLocalNotifications();

    // REGISTER TOKEN
    if (Platform.isIOS) {
      String? apnsToken;

      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();

        if (apnsToken != null && apnsToken.isNotEmpty) {
          debugPrint('🍎 APNS TOKEN READY');
          break;
        }

        debugPrint('🍎 APNS TOKEN belum tersedia, menunggu...');
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null || apnsToken.isEmpty) {
        debugPrint(
          '❌ APNS TOKEN tidak tersedia. '
          'Init akan dicoba lagi saat dipanggil berikutnya.',
        );
        return;
      }
    }

    _initialized = true;

    final token = await messaging.getToken();

    debugPrint('🔥 FCM TOKEN = $token');

    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }

    _tokenSubscription = messaging.onTokenRefresh.listen(_registerToken);

    // FOREGROUND MESSAGE
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      debugPrint('🔥 FCM FOREGROUND MASUK');
      debugPrint('🔥 DATA = ${message.data}');
      debugPrint('🔥 NOTIFICATION = ${message.notification}');

      // Pertahankan logic handler yang sudah ada.
      _handleMessage(message);

      // Android: tampilkan banner/notifikasi lokal.
      // iOS: banner ditampilkan oleh sistem iOS.
      if (Platform.isAndroid) {
        await _showForegroundNotification(message);
      }
    });

    debugPrint('🔥 FCM FOREGROUND LISTENER REGISTERED');
  }

  Future<void> _registerToken(String token) async {
    try {
      // Guest tidak perlu registrasi token ke backend.
      final authToken = await StorageService.readToken();

      if (authToken == null || authToken.isEmpty) {
        return;
      }

      await userRepository.registerFcmToken(token: token);
    } catch (e) {
      debugPrint('[FCM] REGISTER ERROR: $e');
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

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidPlugin?.createNotificationChannel(_foregroundChannel);
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'DMN Play';

    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    debugPrint('[FCM LOCAL] Mulai menampilkan notifikasi');
    debugPrint('[FCM LOCAL] Title: $title');
    debugPrint('[FCM LOCAL] Body: $body');
    debugPrint('[FCM LOCAL] Android: ${Platform.isAndroid}');

    if (body.trim().isEmpty) {
      debugPrint('[FCM LOCAL] GAGAL: body notifikasi kosong');
      return;
    }

    final payload = jsonEncode({
      'type': message.data['type']?.toString() ?? 'notification',
      'notification_id': message.data['notification_id']?.toString() ?? '',
    });

    final notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    try {
      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _foregroundChannel.id,
            _foregroundChannel.name,
            channelDescription: _foregroundChannel.description,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.message,
            color: const Color(0xFFFFC107),
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: 'DMN Play',
            ),
          ),
        ),
        payload: payload,
      );

      debugPrint('[FCM LOCAL] show() selesai: ');
    } catch (e, stackTrace) {
      debugPrint('[FCM LOCAL] ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      Get.toNamed('/notifications');
      return;
    }

    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);

      final type = data['type']?.toString();
      final id = int.tryParse(data['notification_id']?.toString() ?? '');

      if (type == 'account_suspended') {
        return;
      }

      if (id != null && id > 0) {
        Get.toNamed('/notifications/$id');
      } else {
        Get.toNamed('/notifications');
      }
    } catch (e) {
      debugPrint('[LOCAL NOTIFICATION TAP] $e');
      Get.toNamed('/notifications');
    }
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenSubscription?.cancel();

    _messageSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }
}
