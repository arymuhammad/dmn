import 'dart:async';

import 'package:dmn_play/app/data/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helpers/exception.dart';
import '../../../data/models/active_subscription_model.dart';
import '../../../data/models/user_device_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../home/controllers/home_controller.dart';

// SESUAIKAN PATH INI dengan lokasi SuspendedDialog kamu
import '../../login/views/widgets/suspended_dialog.dart';

class AccountController extends GetxController {
  final AuthRepository repository;
  final HomeController homeController;
  final UserRepository userRepository;

  AccountController(this.repository, this.homeController, this.userRepository);

  final isVip = false.obs;
  final user = Rxn<UserModel>();

  HomeModel? get home => homeController.home.value;

  // Paket VIP yang sedang aktif
  ActiveSubscriptionModel? get activeSubscription {
    return home?.activeSubscription;
  }

  final loading = false.obs;

  bool get isLogin => user.value != null;

  final selectedIndex = 0.obs;

  late final PageController pageController;

  final devices = <UserDeviceModel>[].obs;
  final isLoadingDevices = false.obs;
  final deletingDeviceId = RxnInt();

  // ============================================
  // SESSION CHECK
  // ============================================

  Timer? _sessionTimer;

  bool _checkingSession = false;
  bool _suspendDialogShowing = false;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: 0);

    checkSession();
  }

  @override
  void onClose() {
    _stopSessionChecker();

    pageController.dispose();

    super.onClose();
  }

  /// Dipanggil setiap kali user berhasil login.
  ///
  /// Penting karena AccountController tidak dibuat ulang
  /// ketika user A logout lalu user B login.
  void startSessionChecker() {
    // User baru login.
    // Reset status suspend dari session sebelumnya.
    _suspendDialogShowing = false;

    _stopSessionChecker();

    // Cek langsung setelah login.
    checkSession();

    // Cek session secara berkala.
    _sessionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkSession();
    });

    debugPrint('[SESSION] Session checker started');
  }

  void _stopSessionChecker() {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    debugPrint('[SESSION] Session checker stopped');
  }

  Future<void> checkSession() async {
    if (_checkingSession) {
      return;
    }

    final token = await StorageService.readToken();

    if (token == null || token.isEmpty) {
      user.value = null;
      isVip.value = false;

      _stopSessionChecker();

      return;
    }

    // Jangan request auth/me kalau memang belum login
    if (user.value == null) {
      return;
    }

    _checkingSession = true;

    try {
      final me = await repository.me();

      // Jangan update kalau user sudah logout ketika request berjalan.
      final currentToken = await StorageService.readToken();

      if (currentToken == null || currentToken.isEmpty) {
        return;
      }

      user.value = me;
      isVip.value = me.isVip;

      debugPrint('[SESSION] ${me.email ?? ''} masih aktif');
    } on AccountSuspendedException catch (e) {
      debugPrint('======================================');
      debugPrint('[SESSION] ACCOUNT SUSPENDED');
      debugPrint('message : ${e.message}');
      debugPrint('reason  : ${e.reason}');
      debugPrint('======================================');

      await _handleSuspended(e);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('[SESSION] CHECK ERROR');
      debugPrint('error: $e');
      debugPrint('======================================');
      debugPrintStack(stackTrace: stackTrace);

      // Error selain suspend tetap menggunakan
      // logic lama: clear session.
      await StorageService.clear();

      user.value = null;
      isVip.value = false;

      _stopSessionChecker();
    } finally {
      _checkingSession = false;
    }
  }

  Future<void> _handleSuspended(AccountSuspendedException e) async {
    if (_suspendDialogShowing) {
      return;
    }

    _suspendDialogShowing = true;

    // Stop polling supaya tidak request auth/me terus menerus.
    _stopSessionChecker();

    // Clear session lokal.
    await StorageService.clear();

    user.value = null;
    isVip.value = false;

    // Kembali ke halaman login.
    Get.offAllNamed('/login');

    // Beri waktu navigation selesai.
    await Future.delayed(const Duration(milliseconds: 300));

    Get.dialog(
      SuspendedDialog(message: e.reason.isNotEmpty ? e.reason : e.message),
      barrierDismissible: false,
    );
  }

  // ============================================
  // PACKAGE
  // ============================================

  void changePackage(int index) {
    if (selectedIndex.value == index) {
      return;
    }

    selectedIndex.value = index;

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  Future<void> refreshSubscription() async {
    await homeController.loadHome();
  }

  void resetPackage() {
    selectedIndex.value = 0;

    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  // ============================================
  // MANAGE DEVICES
  // ============================================

  Future<void> getDevices() async {
    try {
      isLoadingDevices.value = true;

      final result = await userRepository.getDevices();

      devices.assignAll(result);
    } catch (e, stackTrace) {
      print('======================================');
      print('[GET DEVICES] ERROR');
      print('error: $e');
      print('runtimeType: ${e.runtimeType}');
      print('stackTrace: $stackTrace');
      print('======================================');

      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<void> deleteDevice(UserDeviceModel device) async {
    try {
      deletingDeviceId.value = device.id;

      await userRepository.deleteDevice(device.id);

      devices.removeWhere((item) => item.id == device.id);

      Get.snackbar(
        'Success',
        'Device berhasil dihapus.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      deletingDeviceId.value = null;
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  void clearUser() {
    _stopSessionChecker();

    user.value = null;
    isVip.value = false;

    _suspendDialogShowing = false;
  }
}
