import 'dart:async';

import 'package:dmn_play/app/data/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../data/helpers/exception.dart';
import '../../../data/models/active_subscription_model.dart';
import '../../../data/models/subscription_model.dart';
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

  // ================================================================
  // IN-APP PURCHASE
  // ================================================================

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final isIapLoading = false.obs;

  final Map<String, ProductDetails> _iapProducts = {};

  static const Map<int, String> _subscriptionProductIds = {
    1: 'com.dmnplay.vip.weekly',
    2: 'com.dmnplay.vip.monthly',
    3: 'com.dmnplay.vip.yearly',
  };

  bool _checkingSession = false;
  bool _suspendDialogShowing = false;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: 0);

    _initIap();

    checkSession();
  }

  @override
  void onClose() {
    _stopSessionChecker();

    _purchaseSubscription?.cancel();
    pageController.dispose();

    super.onClose();
  }

  Future<void> _initIap() async {
    try {
      final available = await _inAppPurchase.isAvailable();

      if (!available) {
        debugPrint('[IAP] In-App Purchase tidak tersedia di platform ini');
        return;
      }

      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('[IAP] purchaseStream error: $error');
          isIapLoading.value = false;
        },
      );

      final response = await _inAppPurchase.queryProductDetails(
        _subscriptionProductIds.values.toSet(),
      );

      if (response.error != null) {
        debugPrint('[IAP] query error: ${response.error}');
        return;
      }

      _iapProducts.clear();

      for (final product in response.productDetails) {
        _iapProducts[product.id] = product;

        debugPrint(
          '[IAP] Product: '
          '${product.id} | '
          '${product.price} | '
          '${product.currencyCode}',
        );
      }

      for (final id in _subscriptionProductIds.values) {
        if (!_iapProducts.containsKey(id)) {
          debugPrint('[IAP] Product tidak ditemukan: $id');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[IAP] Init error: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint(
        '[IAP] '
        'product=${purchase.productID} '
        'status=${purchase.status} '
        'transaction=${purchase.purchaseID}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          isIapLoading.value = true;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isIapLoading.value = true;

          try {
            final transactionId = purchase.purchaseID;

            if (transactionId == null || transactionId.isEmpty) {
              throw Exception('Transaction ID Apple tidak ditemukan.');
            }

            debugPrint(
              '[IAP] Verifikasi transaksi ke backend: '
              '$transactionId',
            );

            final response = await repository.verifyApplePurchase(
              transactionId: transactionId,
              environment: 'sandbox',
            );

            debugPrint(
              '[IAP] Backend verification berhasil: '
              '$response',
            );

            /*
           * Purchase baru boleh diselesaikan setelah
           * backend berhasil memverifikasi transaksi Apple.
           */
            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchase);

              debugPrint('[IAP] Purchase berhasil di-complete.');
            }

            /*
           * Reload data Home supaya active_subscription
           * dari backend langsung masuk ke Flutter.
           */
            await refreshSubscription();

            Get.snackbar('Berhasil', 'VIP berhasil diaktifkan.');
          } catch (e, stackTrace) {
            debugPrint('[IAP] Verification error: $e');
            debugPrint('$stackTrace');

            /*
           * JANGAN completePurchase() jika backend gagal.
           *
           * Purchase akan tetap bisa diproses kembali.
           */
            Get.snackbar('Pembelian belum diproses', e.toString());
          } finally {
            isIapLoading.value = false;
          }

          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] Purchase error: ${purchase.error}');

          isIapLoading.value = false;

          Get.snackbar(
            'Purchase Error',
            purchase.error?.message ?? 'Pembelian gagal.',
          );

          break;

        case PurchaseStatus.canceled:
          debugPrint('[IAP] Purchase dibatalkan');

          isIapLoading.value = false;
          break;
      }
    }
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

  Future<void> subscribe(SubscriptionModel subscription) async {
    final productId = _subscriptionProductIds[subscription.id];

    if (productId == null) {
      Get.snackbar('Error', 'Product subscription tidak ditemukan.');
      return;
    }

    final product = _iapProducts[productId];

    if (product == null) {
      Get.snackbar('Error', 'Product belum tersedia di App Store.');

      await _initIap();
      return;
    }

    try {
      isIapLoading.value = true;

      final purchaseParam = PurchaseParam(productDetails: product);

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e, stackTrace) {
      debugPrint('[IAP] Buy error: $e');
      debugPrint('$stackTrace');

      isIapLoading.value = false;

      Get.snackbar('Purchase Error', e.toString());
    }
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
