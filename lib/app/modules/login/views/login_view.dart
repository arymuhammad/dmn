import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:dmn_play/app/data/helpers/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// Close Button
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      final navigator = Get.key.currentState;

                      if (navigator?.canPop() == true) {
                        Get.back();
                      } else {
                        Get.offAllNamed('/navbar');
                      }
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.contentColorWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              AppIcon(height: 60, width: 60),

              const SizedBox(height: 20),

              Text(
                "welcome".tr.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "login to enjoy all DMN Play features".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 50),

              Obx(
                () => _button(
                  color: Colors.white,
                  textColor: Colors.black,
                  icon: SvgPicture.asset(
                    "assets/images/icon/google-icon.svg",
                    width: 16,
                    height: 16,
                  ),
                  title:
                      controller.loading.value
                          ? "Signing in..."
                          : "Continue with Google".tr,
                  enabled: !controller.loading.value,
                  onTap: controller.loginGoogle,
                ),
              ),

              const SizedBox(height: 15),

              _button(
                color: const Color(0xff1877F2),
                textColor: Colors.white,
                icon: const Icon(Icons.facebook, color: Colors.white),
                title: "Continue with Facebook".tr,
                onTap: controller.loginFacebook,
              ),

              const SizedBox(height: 15),

              _button(
                color: Colors.black,
                textColor: Colors.white,
                icon: const Icon(Icons.apple, color: Colors.white),
                title: "Continue with Apple".tr,
                onTap: controller.loginApple,
              ),

              const SizedBox(height: 15),

              _button(
                color: Colors.orange,
                textColor: Colors.white,
                icon: const Icon(Icons.email_outlined),
                title: "Continue with Email",
                onTap: controller.loginEmail,
              ),

              const Spacer(),

              const Text(
                "By continuing, you agree to the\nTerms & Conditions and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button({
    required Color color,
    required Color textColor,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey.shade700,
          foregroundColor: enabled ? textColor : Colors.white54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: enabled ? onTap : null,
        icon: icon,
        label: Text(title),
      ),
    );
  }
}
