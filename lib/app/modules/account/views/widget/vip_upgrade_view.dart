import 'package:dmn_play/app/data/helpers/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipUpgradeView extends StatelessWidget {
  const VipUpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(89, 24, 24, 24),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(height: 80, width: 80),
              const SizedBox(height: 24),

              const Text(
                "VIP Episode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Become a VIP member to unlock all exclusive episodes without limits",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.lock_open),
                  label: const Text(
                    "Unlock / Upgrade to VIP",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _showVipPlans();
                  },
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: Get.back,
                child: const Text(
                  "Later",
                  style: TextStyle(color: Colors.white70, fontSize: 16,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showVipPlans() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xff181818),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Pilih Paket VIP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _planTile(
                title: "VIP Mingguan",
                price: "Rp 15.000",
                subtitle: "Akses penuh selama 7 hari",
              ),

              _planTile(
                title: "VIP Bulanan",
                price: "Rp 39.000",
                subtitle: "Paling populer",
                badge: "HEMAT",
              ),

              _planTile(
                title: "VIP Tahunan paling populer".tr ,  price: "Rp 299.000",
                subtitle: "Hemat hingga 35%",
                badge: "BEST VALUE",
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _planTile({
    required String title,
    required String price,
    required String subtitle,
    String? badge,
  }) {
    return Card(
      color: const Color(0xff252525),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        ),
        trailing: Text(
          price,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onTap: () {
          // TODO: pembayaran
        },
      ),
    );
  }
}

