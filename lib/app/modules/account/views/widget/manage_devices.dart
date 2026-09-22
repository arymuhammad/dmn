import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helpers/app_colors.dart';
import '../../../../data/models/user_device_model.dart';
import '../../controllers/account_controller.dart';

class ManageDevicesView extends StatelessWidget {
  const ManageDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountController>();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Manage Devices',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Obx(() {
        // ========================================================
        // LOADING
        // ========================================================

        if (controller.isLoadingDevices.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.contentColorYellow,
            ),
          );
        }

        // ========================================================
        // EMPTY
        // ========================================================

        if (controller.devices.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.getDevices,
            color: AppColors.contentColorYellow,
            backgroundColor: const Color(0xFF1E1C1C),

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),

                Icon(Icons.devices_outlined, size: 64, color: Colors.white24),

                SizedBox(height: 16),

                Center(
                  child: Text(
                    'No devices found',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        // ========================================================
        // DEVICE LIST
        // ========================================================

        return RefreshIndicator(
          onRefresh: controller.getDevices,
          color: AppColors.contentColorYellow,
          backgroundColor: const Color(0xFF1E1C1C),

          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),

            itemCount: controller.devices.length,

            separatorBuilder: (_, __) {
              return const SizedBox(height: 12);
            },

            itemBuilder: (context, index) {
              final device = controller.devices[index];

              return _DeviceCard(
                device: device,
                isDeleting: controller.deletingDeviceId.value == device.id,
                onDelete: () {
                  _confirmDelete(device, controller);
                },
              );
            },
          ),
        );
      }),
    );
  }

  static void _confirmDelete(
    UserDeviceModel device,
    AccountController controller,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1C1C),

        title: const Text(
          'Remove Device',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        content: Text(
          'Are you sure you want to remove '
          '${device.deviceName.isNotEmpty ? device.deviceName : 'this device'}?',
          style: const TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),

          TextButton(
            onPressed: () {
              Get.back();

              controller.deleteDevice(device);
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final UserDeviceModel device;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAndroid = device.platform.toLowerCase() == 'android';

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: AppColors.contentColorYellow.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              isAndroid ? Icons.android : Icons.phone_iphone,
              color: AppColors.contentColorYellow,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName.isNotEmpty
                      ? device.deviceName
                      : 'Unknown Device',

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  device.platform.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          if (isDeleting)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.redAccent,
              ),
            )
          else
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }
}
