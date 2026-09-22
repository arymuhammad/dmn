import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _google = GoogleSignIn(
    scopes: const ['email'],
    serverClientId:
        '334660427780-thi5m2sf2fhgnkdvo1m4kq62lg6l5jnf.apps.googleusercontent.com',
  );

  Future<String?> login() async {
    await _google.signOut();

    final account = await _google.signIn();

    if (account == null) return null;

    final auth = await account.authentication;

    return auth.idToken;
  }

  Future logout() async {
    await _google.signOut();
  }
}
