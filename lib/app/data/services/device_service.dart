import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _deviceIdKey = 'dmnplay_device_id';
  // ============================================================
  // DEVICE ID
  // ============================================================

  Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    deviceId = const Uuid().v4();

    await _storage.write(key: _deviceIdKey, value: deviceId);

    return deviceId;
  }

  // ============================================================
  // PLATFORM
  // ============================================================

  Future<String> getPlatform() async {
    if (Platform.isAndroid) {
      return 'android';
    }

    if (Platform.isIOS) {
      return 'ios';
    }

    return Platform.operatingSystem;
  }

  // ============================================================
  // DEVICE NAME
  // ============================================================

  Future<String> getDeviceName() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;

      final manufacturer = info.manufacturer.trim();
      final model = info.model.trim();

      if (manufacturer.isNotEmpty &&
          model.isNotEmpty &&
          !model.toLowerCase().contains(manufacturer.toLowerCase())) {
        return '$manufacturer $model';
      }

      return model.isNotEmpty ? model : 'Android Device';
    }

    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;

      final name = info.name.trim();

      if (name.isNotEmpty) {
        return name;
      }

      return info.utsname.machine;
    }

    return Platform.localHostname;
  }
}
