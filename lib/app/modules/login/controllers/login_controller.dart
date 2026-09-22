import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/helpers/exception.dart';
import '../../../data/models/login_result.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/push_notification_service.dart';
import '../../account/controllers/account_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../views/widgets/device_limit_dialog.dart';
import '../views/widgets/login_loading_dialog.dart';
import '../views/widgets/logout_dialog.dart';
import '../views/widgets/suspended_dialog.dart';

class LoginController extends GetxController {
  final AuthRepository repository;

  LoginController(this.repository);

  final loading = false.obs;

  Future<void> loginGoogle() async {
    try {
      loading.value = true;

      LoginLoadingDialog.show();

      final result = await repository.loginGoogle();

      LoginLoadingDialog.close();

      if (result.cancelled) {
        return;
      }

      await onLoginSuccess(result);
    } on DeviceLimitException catch (e) {
      LoginLoadingDialog.close();

      _showDeviceLimitDialog(e);
    } on AccountSuspendedException catch (e) {
      LoginLoadingDialog.close();

      _showSuspendedDialog(e);
    } on PlatformException catch (e, stackTrace) {
      LoginLoadingDialog.close();

      debugPrint('================ GOOGLE SIGN IN ERROR ================');
      debugPrint('code    : ${e.code}');
      debugPrint('message : ${e.message}');
      debugPrint('details : ${e.details}');
      debugPrint('========================================================');

      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar(
        'Google Login',
        '${e.code}\n${e.message ?? ''}\n${e.details ?? ''}',
        duration: const Duration(seconds: 8),
      );
    } catch (e, stackTrace) {
      LoginLoadingDialog.close();

      debugPrint('================ LOGIN ERROR ================');
      debugPrint('error: $e');
      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar('Login', e.toString(), duration: const Duration(seconds: 8));
    } finally {
      loading.value = false;
    }
  }

  void _showDeviceLimitDialog(DeviceLimitException e) {
    Get.dialog(
      DeviceLimitDialog(
        message: e.message,
        maxDevices: e.maxDevices,
        devices: e.devices,
      ),
      barrierDismissible: false,
    );
  }

  void loginFacebook() {
    Get.snackbar("Coming Soon", "facebook_login_belum_tersedia".tr);
  }

  void loginApple() {
    Get.snackbar("coming_soon".tr, "apple_login_belum_tersedia".tr);
  }

  void loginEmail() {
    Get.toNamed("/login-email");
  }

  Future<void> onLoginSuccess(LoginResult result) async {
    final account = Get.find<AccountController>();

    account.user.value = result.user;
    account.isVip.value = result.user!.isVip;

    // PENTING:
    // Restart session checker untuk user yang baru login.
    account.startSessionChecker();

    await Get.find<PushNotificationService>().init();

    // ==========================================================
    // REFRESH DATA DULU
    // ==========================================================

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadHome(isRefresh: true);
    }

    if (Get.isRegistered<HistoryController>()) {
      await Get.find<HistoryController>().loadHistory();
    }

    // ==========================================================
    // BARU PINDAH KE NAVBAR
    // ==========================================================

    Get.offAllNamed('/navbar');
  }

  void logout() {
    LogoutDialog.show(onConfirm: _performLogout);
  }

  Future<void> _performLogout() async {
    await repository.logout();

    final account = Get.find<AccountController>();
    account.clearUser();

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadHome(isRefresh: true);
    }

    if (Get.isRegistered<HistoryController>()) {
      await Get.find<HistoryController>().loadHistory();
    }

    Get.back();
  }

  void _showSuspendedDialog(AccountSuspendedException e) {
    Get.dialog(
      SuspendedDialog(message: e.reason.isNotEmpty ? e.reason : e.message),
      barrierDismissible: false,
    );
  }
}
