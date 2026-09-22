import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = "token";

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: tokenKey,
      value: token,
    );
  }

  static Future<String?> readToken() async {
    return await _storage.read(
      key: tokenKey,
    );
  }

  static Future<void> removeToken() async {
    await _storage.delete(
      key: tokenKey,
    );
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}