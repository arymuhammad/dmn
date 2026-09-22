import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:dmn_play/app/modules/account/views/widget/subscriptions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/translations/controller/language_controller.dart';
import 'widget/header.dart';
import 'widget/manage_devices.dart';
import 'widget/vip_card.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // FIXED PROFILE HEADER
            // =====================================================
            ProfileHeader(),

            // =====================================================
            // SCROLLABLE CONTENT
            // =====================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  const SizedBox(height: 20),

                  // =================================================
                  // VIP CARD
                  // =================================================
                  Obx(() {
                    if (controller.activeSubscription != null) {
                      return const SizedBox.shrink();
                    }

                    return const Column(
                      children: [VipCard(), SizedBox(height: 24)],
                    );
                  }),

                  _SectionTitle('account settings'),

                  _SettingTile(icon: Icons.person_outline, title: 'account'),

                  Obx(() {
                    if (!controller.isLogin) {
                      return const SizedBox.shrink();
                    }

                    return _SettingTile(
                      icon: Icons.devices_outlined,
                      title: 'manage device',
                      onTap: () async {
                        await controller.getDevices();

                        Get.to(() => const ManageDevicesView());
                      },
                    );
                  }),

                  _SettingTile(
                    icon: Icons.language,
                    title: 'language',
                    subtitle: Obx(
                      () => Text(
                        Get.find<LanguageController>().currentLanguageName,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    onTap: showLanguageDialog,
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('payment & transaction'),

                  _SettingTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'subscription plan',
                    onTap: () {
                      final subscriptions = controller.home?.subscriptions;

                      if (subscriptions == null) {
                        Get.snackbar(
                          'please_wait'.tr,
                          'subscription data is still loading'.tr,
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                        );
                        return;
                      }
                      // Reset tab ke posisi 0
                      controller.resetPackage();

                      Get.to(
                        () => SubscriptionPrice(
                          activeSubscription: controller.activeSubscription,
                        ),
                      );
                    },
                  ),

                  _SettingTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'transaction history',
                  ),

                  const SizedBox(height: 24),

                  _SettingTile(icon: Icons.help_outline, title: 'help center'),

                  _SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'privacy policy',
                  ),

                  _SettingTile(
                    icon: Icons.description_outlined,
                    title: 'terms of use',
                  ),

                  const SizedBox(height: 32),

                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.tr.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? subtitle;
  final void Function()? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.contentColorYellow),
      title: Text(
        title.tr.capitalize ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}

void showLanguageDialog() {
  final controller = Get.find<LanguageController>();

  Get.dialog(
    Obx(
      () => AlertDialog(
        backgroundColor: const Color(0xFF1E1C1C),

        title: Text(
          'language'.tr.capitalizeFirst ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              controller.languages.entries.map((entry) {
                final selected = controller.currentLanguageCode == entry.key;

                return ListTile(
                  contentPadding: EdgeInsets.zero,

                  title: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),

                  trailing:
                      selected
                          ? const Icon(
                            Icons.check_circle,
                            color: AppColors.contentColorYellow,
                          )
                          : null,

                  onTap: () async {
                    await controller.changeLanguage(entry.key);

                    Get.back();
                  },
                );
              }).toList(),
        ),
      ),
    ),
  );
}
