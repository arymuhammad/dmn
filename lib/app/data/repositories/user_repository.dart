import '../models/user_device_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/device_service.dart';

class UserRepository {
  final ApiClient api;
  final DeviceService deviceService;

  UserRepository(this.api, this.deviceService);

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  Future<UserModel> getMe() async {
    final response = await api.get('auth/me');

    return UserModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] ?? {}),
    );
  }

  // ============================================================
  // GET USER DEVICES
  // ============================================================

  Future<List<UserDeviceModel>> getDevices() async {
    final response = await api.get('user/manage-devices');

    final body = Map<String, dynamic>.from(response.data ?? {});

    final data = Map<String, dynamic>.from(body['data'] ?? {});

    final List devices = data['devices'] ?? [];

    return devices
        .map(
          (item) => UserDeviceModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ============================================================
  // DELETE DEVICE
  // ============================================================

  Future<void> deleteDevice(int deviceId) async {
    await api.delete('user/devices/delete/$deviceId');
  }

  // ============================================================
  // REGISTER / UPDATE FCM DEVICE
  // ============================================================

  Future<void> registerFcmToken({required String token}) async {
    final deviceId = await deviceService.getDeviceId();
    final platform = await deviceService.getPlatform();
    final deviceName = await deviceService.getDeviceName();

    await api.post(
      'auth/register-fcmtoken',
      body: {
        'token': token,
        'platform': platform,
        'device_name': deviceName,
        'device_id': deviceId,
      },
    );
  }
}
