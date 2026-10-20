import 'dart:async';
import 'dart:io';

import 'package:dmn_play/app/data/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../data/helpers/exception.dart';
import '../../../data/helpers/iap_snackbar.dart';
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

class AccountController extends GetxController with WidgetsBindingObserver {
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

  final storeProducts = <ProductDetails>[].obs;

  // Produk yang dipilih sebelum user login.
  // Simpan ID agar bisa dicari kembali setelah login.
  String? _pendingSubscriptionProductId;

  static const List<String> subscriptionProductIds = [
    'com.dmnplay.vip.weekly',
    'com.dmnplay.vip.monthly',
    'com.dmnplay.vip.yearly',
  ];

  bool _checkingSession = false;
  bool _suspendDialogShowing = false;

  bool _isPurchaseDialogOpen = false;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: 0);

    _initIap();

    checkSession();
  }

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[VIP] App kembali aktif, refresh subscription');
      refreshSubscription();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    _stopSessionChecker();

    _purchaseSubscription?.cancel();
    pageController.dispose();

    super.onClose();
  }

  Future<void> _initIap() async {
    debugPrint('[IAP DEBUG] _initIap() dipanggil');

    try {
      isIapLoading.value = true;

      final available = await _inAppPurchase.isAvailable();

      debugPrint('[IAP DEBUG] Store available: $available');
      debugPrint('[IAP DEBUG] Expected IDs: $subscriptionProductIds');

      if (!available) {
        debugPrint('[IAP] Store tidak tersedia');
        return;
      }

      _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('[IAP] purchaseStream error: $error');
          isIapLoading.value = false;
        },
      );

      final response = await _inAppPurchase.queryProductDetails(
        subscriptionProductIds.toSet(),
      );

      debugPrint('[IAP DEBUG] Error: ${response.error}');
      debugPrint('[IAP DEBUG] Not found IDs: ${response.notFoundIDs}');

      if (response.error != null) {
        debugPrint('[IAP] Query error: ${response.error}');
        return;
      }

      _iapProducts.clear();

      for (final product in response.productDetails) {
        _iapProducts[product.id] = product;

        debugPrint(
          '[IAP] Product: ${product.id} | '
          '${product.price} | ${product.currencyCode}',
        );
      }

      // Urutan paket tetap weekly, monthly, yearly.
      storeProducts.assignAll(
        subscriptionProductIds
            .where((id) => _iapProducts.containsKey(id))
            .map((id) => _iapProducts[id]!)
            .toList(),
      );

      for (final id in subscriptionProductIds) {
        if (!_iapProducts.containsKey(id)) {
          debugPrint('[IAP] Product tidak ditemukan: $id');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[IAP] Init error: $e');
      debugPrint('$stackTrace');
    } finally {
      isIapLoading.value = false;
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
          _showPurchaseLoading();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isIapLoading.value = true;
          _showPurchaseLoading();

          try {
            final transactionId = purchase.purchaseID;

            debugPrint(
              '[IAP] Memverifikasi ${purchase.productID} '
              'di platform ${Platform.operatingSystem}',
            );

            Map<String, dynamic> response;

            if (Platform.isAndroid) {
              final purchaseToken =
                  purchase.verificationData.serverVerificationData;

              if (purchaseToken.isEmpty) {
                throw Exception('Google Play purchase token tidak ditemukan.');
              }

              response = await repository.verifyGooglePurchase(
                productId: purchase.productID,
                purchaseToken: purchaseToken,
              );
            } else if (Platform.isIOS) {
              if (transactionId == null || transactionId.isEmpty) {
                throw Exception('Transaction ID Apple tidak ditemukan.');
              }

              response = await repository.verifyApplePurchase(
                transactionId: transactionId,
                environment: 'sandbox',
              );
            } else {
              throw Exception('Platform pembelian tidak didukung.');
            }

            debugPrint('[IAP] Backend verification berhasil: $response');

            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchase);
            }

            await refreshSubscription();

            _hidePurchaseLoading();
            isIapLoading.value = false;

            showIapSnackbar(
              title: 'VIP Aktif!',
              message: 'Selamat! Langganan VIP DMN Play berhasil diaktifkan.',
            );
          } catch (e, stackTrace) {
            debugPrint('[IAP] Verification error: $e');
            debugPrint('$stackTrace');

            _hidePurchaseLoading();
            isIapLoading.value = false;

            showIapSnackbar(
              title: 'Pembelian belum diproses',
              message: e.toString(),
              isError: true,
            );
          }

          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] Purchase error: ${purchase.error}');

          _hidePurchaseLoading();
          isIapLoading.value = false;

          showIapSnackbar(
            title: 'Pembelian gagal',
            message: purchase.error?.message ?? 'Silakan coba kembali.',
            isError: true,
          );

          break;

        case PurchaseStatus.canceled:
          debugPrint('[IAP] Purchase dibatalkan');

          _hidePurchaseLoading();
          isIapLoading.value = false;

          break;
      }
    }
  }

  void _showPurchaseLoading() {
    if (_isPurchaseDialogOpen) return;

    _isPurchaseDialogOpen = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: const Dialog(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Menunggu proses pembayaran Google Play...'),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hidePurchaseLoading() {
    if (!_isPurchaseDialogOpen) return;

    _isPurchaseDialogOpen = false;

    if (Get.isDialogOpen == true) {
      Get.back();
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

    // // Jangan request auth/me kalau memang belum login
    // if (user.value == null) {
    //   return;
    // }

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

      // Session checker cukup memvalidasi sesi dan memperbarui profil.
      // Data Home dan subscription dimuat melalui proses refresh tersendiri.

      debugPrint(
        '[VIP STATUS] '
        'isVip=${isVip.value} | '
        'activeSubscription=${homeController.home.value?.activeSubscription != null}',
      );

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

  // Future<void> subscribe(ProductDetails product) async {
  //   if (!_iapProducts.containsKey(product.id)) {
  //     Get.snackbar('Error', 'Produk tidak tersedia di store.');
  //     await _initIap();
  //     return;
  //   }

  //   try {
  //     isIapLoading.value = true;

  //     final purchaseParam = PurchaseParam(productDetails: product);

  //     await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  //   } catch (e, stackTrace) {
  //     debugPrint('[IAP] Buy error: $e');
  //     debugPrint('$stackTrace');

  //     isIapLoading.value = false;

  //     Get.snackbar('Purchase Error', e.toString());
  //   }
  // }

  Future<void> subscribe(ProductDetails product) async {
    if (!isLogin) {
      _pendingSubscriptionProductId = product.id;
      Get.toNamed('/login');
      return;
    }

    if (isIapLoading.value) return;

    if (!_iapProducts.containsKey(product.id)) {
      showIapSnackbar(
        title: 'Produk tidak tersedia',
        message: 'Silakan coba lagi sebentar.',
        isError: true,
      );
      await _initIap();
      return;
    }

    try {
      isIapLoading.value = true;
      _showPurchaseLoading();

      final purchaseParam = PurchaseParam(
        productDetails: _iapProducts[product.id]!,
      );

      final launched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('[IAP] Purchase flow launched: $launched');
    } catch (e, stackTrace) {
      debugPrint('[IAP] Buy error: $e');
      debugPrint('$stackTrace');

      _hidePurchaseLoading();
      isIapLoading.value = false;

      showIapSnackbar(
        title: 'Purchase Error',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> processPendingSubscription() async {
    final productId = _pendingSubscriptionProductId;

    if (productId == null || productId.isEmpty) return;

    // Pastikan sesi login sudah tersedia.
    if (!isLogin) return;

    // Hapus pilihan yang tertahan sebelum memulai billing,
    // agar login berikutnya tidak mengulang pembelian.
    _pendingSubscriptionProductId = null;

    try {
      // Produk mungkin belum selesai dimuat ketika login selesai.
      if (!_iapProducts.containsKey(productId)) {
        await _initIap();
      }

      final product = _iapProducts[productId];

      if (product == null) {
        showIapSnackbar(
          title: 'Produk tidak tersedia',
          message:
              'Paket yang dipilih tidak ditemukan di Google Play. '
              'Silakan pilih paket kembali.',
          isError: true,
        );
        return;
      }

      await subscribe(product);
    } catch (e, stackTrace) {
      debugPrint('[IAP] Pending subscription error: $e');
      debugPrint('$stackTrace');

      showIapSnackbar(
        title: 'Purchase Error',
        message: e.toString(),
        isError: true,
      );
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
    final token = await StorageService.readToken();

    if (token == null || token.isEmpty) {
      user.value = null;
      isVip.value = false;
      return;
    }

    try {
      await homeController.loadHome();

      final me = await repository.me();

      final currentToken = await StorageService.readToken();

      if (currentToken == null ||
          currentToken.isEmpty ||
          currentToken != token) {
        return;
      }

      user.value = me;
      isVip.value = me.isVip;

      debugPrint(
        '[VIP REFRESH] '
        'isVip=${isVip.value} | '
        'activeSubscription=${activeSubscription != null}',
      );
    } catch (e, stackTrace) {
      debugPrint('[VIP REFRESH] Error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
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

      showIapSnackbar(title: 'Error', message: e.toString(), isError: true);
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<void> deleteDevice(UserDeviceModel device) async {
    try {
      deletingDeviceId.value = device.id;

      await userRepository.deleteDevice(device.id);

      devices.removeWhere((item) => item.id == device.id);

      showIapSnackbar(title: 'Success', message: 'Device berhasil dihapus.');
    } catch (e) {
      showIapSnackbar(title: 'Error', message: e.toString(), isError: true);
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
