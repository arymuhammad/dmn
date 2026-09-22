import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ============================================================
  // DEVICE ID
  // ============================================================

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.id;
    }

    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor ?? '';
    }

    return Platform.localHostname;
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
          !model.toLowerCase().contains(
            manufacturer.toLowerCase(),
          )) {
        return '$manufacturer $model';
      }

      return model.isNotEmpty
          ? model
          : 'Android Device';
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