import 'user_model.dart';

class LoginResult {
  final bool success;
  final bool cancelled;
  final UserModel? user;

  LoginResult({
    required this.success,
    required this.cancelled,
    this.user,
  });
}