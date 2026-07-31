import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:dmn_play/app/modules/navbar/controllers/navbar_controller_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernBottomBar extends GetView<NavbarController> {
  const ModernBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      // margin: const EdgeInsets.all(16),
      // padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(24),
        //   topRight: Radius.circular(24),
        // ),
        boxShadow: const [
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
          // if (c.showEpisodePlayer) {
          //   return const SizedBox(height: 0);
          // }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(
                controller: c,
                icon: Icons.home_rounded,
                label: "Home",
                index: 0,
              ),
              _item(
                controller: c,
                icon: Icons.explore_rounded,
                label: "Discover",
                index: 1,
              ),
              _item(
                controller: c,
                icon: Icons.bookmark_rounded,
                label: "Bookmark",
                index: 2,
              ),
              _item(
                controller: c,
                icon: Icons.person_rounded,
                label: "Account",
                index: 3,
              ),
            ],
          );
        },
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
      onTap: () {
        controller.changeTab(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.contentColorYellow.withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
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
                          label,
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
