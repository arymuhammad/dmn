import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipCard extends StatelessWidget {
  const VipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffF4D03F), Color(0xffF39C12)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'vip account'.tr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'become a vip member'.tr.toUpperCase(),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // BENEFITS
          // =====================================================
          Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    _Benefit(
      icon: Icons.movie_filter_outlined,
      title: 'exclusive drama'.tr,
    ),
    _Benefit(
      icon: Icons.play_circle_outline,
      title: 'anytime streaming'.tr,
    ),
    _Benefit(
      icon: Icons.all_inclusive,
      title: 'unlimited viewing'.tr,
    ),
    _Benefit(
      icon: Icons.person_outline,
      title: 'personal content'.tr,
    ),
    _Benefit(
      icon: Icons.devices_outlined,
      title: 'max. 2 devices'.tr,
    ),
    _Benefit(
      icon: Icons.high_quality_outlined,
      title: 'HD video quality'.tr,
    ),
  ],
),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('upgrade now'.tr.capitalize ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Benefit({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            title.capitalize ?? '',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
