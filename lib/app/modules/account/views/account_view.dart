import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget/header.dart';
import 'widget/vip_card.dart';

class AccountView extends GetView {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ProfileHeader(),
            SizedBox(height: 20),

            VipCard(),
            SizedBox(height: 24),

            _SectionTitle('Account Settings'),
            _SettingTile(icon: Icons.person_outline, title: 'Account'),
            _SettingTile(icon: Icons.devices_outlined, title: 'Manage Device'),

            SizedBox(height: 24),

            _SectionTitle('Payment & Transaction'),
            _SettingTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Subscription Plan',
            ),
            _SettingTile(
              icon: Icons.receipt_long_outlined,
              title: 'Transaction History',
            ),

            SizedBox(height: 24),

            _SettingTile(icon: Icons.help_outline, title: 'Help Center'),
            _SettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
            ),
            _SettingTile(
              icon: Icons.description_outlined,
              title: 'Terms of Use',
            ),

            SizedBox(height: 32),

            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.white38),
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
        title.toUpperCase(),
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

  const _SettingTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {},
    );
  }
}
