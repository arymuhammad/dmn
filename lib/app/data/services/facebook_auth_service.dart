import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  Future<String?> login() async {
    await FacebookAuth.instance.logOut();

    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status != LoginStatus.success) {
      return null;
    }

    return result.accessToken?.tokenString;
  }

  Future<void> logout() async {
    await FacebookAuth.instance.logOut();
  }
}
