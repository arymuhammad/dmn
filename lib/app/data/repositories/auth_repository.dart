import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../helpers/exception.dart';
import '../models/login_result.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/device_service.dart';
import '../services/google_auth_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiClient api;

  final GoogleAuthService google;
  final DeviceService deviceService;
  // final FacebookAuthService facebook;

  // final StorageService storage;

  AuthRepository({
    required this.api,
    required this.google,
    required this.deviceService,
    // required this.facebook,
    // required this.storage,
  });

  Future<LoginResult> loginGoogle() async {
    final idToken = await google.login();

    if (idToken == null) {
      return LoginResult(success: false, cancelled: true);
    }

    try {
      final deviceId = await deviceService.getDeviceId();
      final deviceName = await deviceService.getDeviceName();
      final platform = await deviceService.getPlatform();

      final response = await api.post(
        "auth/google",
        body: {
          "id_token": idToken,
          "device_id": deviceId,
          "device_name": deviceName,
          "platform": platform,
        },
      );

      debugPrint('GOOGLE LOGIN STATUS: ${response.statusCode}');
      debugPrint('GOOGLE LOGIN RESPONSE: ${response.data}');

      final json = response.data;

      /*
 * ============================================================
 * RESPONSE ERROR
 * ============================================================
 */

      if (json is Map && json["success"] != true) {
        final statusCode = response.statusCode;
        final data = json["data"];

        /*
   * ACCOUNT SUSPENDED
   *
   * Dipakai jika API mengembalikan HTTP 403
   * sebagai response normal.
   */
        if (statusCode == 403) {
          String reason = '';

          if (data is Map) {
            reason = data["suspend_reason"]?.toString() ?? '';
          }

          throw AccountSuspendedException(
            message:
                json["message"]?.toString() ?? 'Akun Anda telah ditangguhkan.',
            reason: reason,
          );
        }

        throw Exception(json["message"]?.toString() ?? 'Login gagal.');
      }

      if (json is! Map ||
          json["data"] is! Map ||
          json["data"]["token"] == null) {
        throw Exception('Response login tidak valid.');
      }

      await StorageService.saveToken(json["data"]["token"].toString());

      return LoginResult(
        success: true,
        cancelled: false,
        user: UserModel.fromJson(json["data"]["user"]),
      );
    } on DioException catch (e) {
      final apiError = e.error;

      if (apiError is ApiException) {
        final data = apiError.data;

        /*
   * ==========================================================
   * DEVICE LIMIT
   * ==========================================================
   */

        if (apiError.statusCode == 403 &&
            data is Map &&
            data['data'] is Map &&
            data['data']['code'] == 'DEVICE_LIMIT_REACHED') {
          final deviceData = data['data'] as Map;

          final rawDevices = deviceData['devices'];

          final devices = <Map<String, dynamic>>[];

          if (rawDevices is List) {
            for (final device in rawDevices) {
              if (device is Map) {
                devices.add(Map<String, dynamic>.from(device));
              }
            }
          }

          throw DeviceLimitException(
            message:
                apiError.message.isNotEmpty
                    ? apiError.message
                    : 'Batas perangkat tercapai.',
            maxDevices:
                int.tryParse(deviceData['max_devices']?.toString() ?? '') ?? 3,
            devices: devices,
          );
        }

        /*
   * ==========================================================
   * ACCOUNT SUSPENDED
   * ==========================================================
   */

        if (apiError.statusCode == 403) {
          String reason = '';

          if (data is Map && data['data'] is Map) {
            final responseData = data['data'] as Map;

            reason = responseData['suspend_reason']?.toString() ?? '';
          }

          throw AccountSuspendedException(
            message:
                apiError.message.isNotEmpty
                    ? apiError.message
                    : 'Akun Anda telah ditangguhkan.',
            reason: reason,
          );
        }
      }

      rethrow;
    }
  }

  // Future<LoginResult> loginFacebook() async {
  //   final accessToken = await facebook.login();

  //   if (accessToken == null) {
  //     return LoginResult(success: false, cancelled: true);
  //   }

  //   final response = await api.post(
  //     "auth/facebook",
  //     body: {"access_token": accessToken},
  //   );

  //   final json = response.data;

  //   if (json["success"] != true) {
  //     throw Exception(json["message"]);
  //   }

  //   await StorageService.saveToken(json["data"]["token"]);

  //   return LoginResult(
  //     success: true,
  //     cancelled: false,
  //     user: UserModel.fromJson(json["data"]["user"]),
  //   );
  // }
  Future<UserModel> me() async {
    try {
      final response = await api.get("auth/me");

      return UserModel.fromJson(response.data["data"]);
    } on DioException catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('[AUTH ME] DIO ERROR');
      debugPrint('statusCode : ${e.response?.statusCode}');
      debugPrint('message    : ${e.message}');
      debugPrint('error      : ${e.error}');
      debugPrint('response   : ${e.response?.data}');
      debugPrint('======================================');

      final apiError = e.error;

      if (apiError is ApiException) {
        final data = apiError.data;

        debugPrint('[AUTH ME] ApiException status: ${apiError.statusCode}');
        debugPrint('[AUTH ME] ApiException data  : $data');

        // ==========================================
        // ACCOUNT SUSPENDED
        // ==========================================

        if (apiError.statusCode == 403) {
          String reason = '';

          if (data is Map) {
            // Response normal:
            //
            // {
            //   success: false,
            //   message: ...,
            //   data: {
            //      suspend_reason: ...
            //   }
            // }

            if (data['data'] is Map) {
              final responseData = data['data'] as Map;

              reason = responseData['suspend_reason']?.toString() ?? '';
            }

            // Fallback kalau suspend_reason berada langsung
            // di root response.
            if (reason.isEmpty) {
              reason = data['suspend_reason']?.toString() ?? '';
            }
          }

          throw AccountSuspendedException(
            message:
                apiError.message.isNotEmpty
                    ? apiError.message
                    : 'Akun Anda telah ditangguhkan.',
            reason: reason,
          );
        }
      }

      debugPrint('[AUTH ME] Re-throw original DioException');

      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  // Future logout() async {
  //   // ============================================================
  //   // LOGOUT FROM DEVICE
  //   // ============================================================
  //   await api.post('auth/logout');
  //   //=============================================================

  //   await google.logout();
  //   // await facebook.logout();
  //   await StorageService.clear();
  // }

  Future<void> logout() async {
    try {
      // ============================================================
      // LOGOUT FROM DEVICE
      // ============================================================
      await api.post('auth/logout');
    } catch (e) {
      // Token sudah tidak valid / expired / unauthorized.
      // Tetap lanjutkan logout lokal.
      debugPrint('Server logout gagal: $e');
    }

    // ============================================================
    // LOGOUT GOOGLE
    // ============================================================
    try {
      await google.logout();
    } catch (e) {
      debugPrint('Google logout gagal: $e');
    }

    // ============================================================
    // CLEAR LOCAL SESSION
    // ============================================================
    await StorageService.clear();
  }
}
