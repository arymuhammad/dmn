
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyController extends GetxController {
  late final WebViewController webController;

  final isLoading = true.obs;
  final hasError = false.obs;
  final progress = 0.obs;

  static const String url =
      'https://dmnplay.co.id/privacy-policy.html';

  @override
  void onInit() {
    super.onInit();

    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            progress.value = value;
          },
          onPageStarted: (_) {
            isLoading.value = true;
            hasError.value = false;
          },
          onPageFinished: (_) {
            isLoading.value = false;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              hasError.value = true;
              isLoading.value = false;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<void> reloadPage() async {
    hasError.value = false;
    isLoading.value = true;
    await webController.reload();
  }
}
