import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helpers/app_colors.dart';

class DeviceLimitDialog extends StatelessWidget {
  final String message;
  final int maxDevices;
  final List<Map<String, dynamic>> devices;

  const DeviceLimitDialog({
    super.key,
    required this.message,
    required this.maxDevices,
    required this.devices,
  });

  String _formatLastSeen(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '';
    }

    return value.toString();
  }

  IconData _deviceIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;

      case 'android':
        return Icons.android;

      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C1C),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white.withValues(alpha: .14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .45),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // TITLE
            // =========================================================
            Text(
              'Batas Perangkat Tercapai',
              style: TextStyle(
                color: AppColors.contentColorWhite,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            // =========================================================
            // MESSAGE
            // =========================================================
            Text(
              message,
              style: TextStyle(
                color: AppColors.contentColorWhite.withValues(alpha: .65),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Perangkat terdaftar ($maxDevices):',
              style: TextStyle(
                color: AppColors.contentColorWhite,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // =========================================================
            // DEVICE LIST
            // =========================================================
            Container(
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: .08)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: devices.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 14,
                    color: Colors.white.withValues(alpha: .07),
                  );
                },
                itemBuilder: (_, index) {
                  final device = devices[index];

                  final deviceName =
                      device['device_name']?.toString().trim().isNotEmpty ==
                              true
                          ? device['device_name'].toString()
                          : 'Perangkat ${index + 1}';

                  final platform = device['platform']?.toString().trim() ?? '';

                  final lastSeen = _formatLastSeen(device['last_seen_at']);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // =================================================
                        // DEVICE ICON
                        // =================================================
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _deviceIcon(platform),
                            color: AppColors.contentColorWhite.withValues(
                              alpha: .8,
                            ),
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // =================================================
                        // DEVICE INFO
                        // =================================================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.contentColorWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                [
                                  if (platform.isNotEmpty) platform,
                                  if (lastSeen.isNotEmpty)
                                    'Terakhir aktif: $lastSeen',
                                ].join(' • '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.contentColorWhite.withValues(
                                    alpha: .5,
                                  ),
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            // =========================================================
            // BUTTON
            // =========================================================
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contentColorYellow,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
