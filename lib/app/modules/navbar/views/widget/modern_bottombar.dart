import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:dmn_play/app/modules/navbar/controllers/navbar_controller_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernBottomBar extends GetView<NavbarController> {
  const ModernBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: Offset(0, 8),
                color: Colors.black26,
              ),
            ],
          ),
          child: GetBuilder<NavbarController>(
            id: 'navbar',
            builder: (c) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _item(
                    controller: c,
                    icon: Icons.home_rounded,
                    label: "home".tr,
                    index: 0,
                  ),
                  _item(
                    controller: c,
                    icon: Icons.movie_filter,
                    label: "mix".tr,
                    index: 1,
                  ),
                  _item(
                    controller: c,
                    icon: Icons.bookmark_rounded,
                    label: "history".tr,
                    index: 2,
                  ),
                  _item(
                    controller: c,
                    icon: Icons.person_rounded,
                    label: "account".tr,
                    index: 3,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _item({
    required NavbarController controller,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.contentColorYellow.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.contentColorYellow : Colors.white54,
              size: 30,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 10),
              child:
                  selected
                      ? Padding(
                        key: ValueKey(label),
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label.tr.capitalizeFirst ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
