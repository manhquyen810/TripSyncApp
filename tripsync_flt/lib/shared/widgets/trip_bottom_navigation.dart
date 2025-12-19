import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';

class TripBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const TripBottomNavigation({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/plane.png',
              label: 'Plane',
              isActive: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/document.png',
              label: 'Upload',
              isActive: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/coin.png',
              label: 'Chi tiêu',
              isActive: currentIndex == 2,
              onTap: () => onTap?.call(2),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/list.png',
              label: 'Checklist',
              isActive: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
          ),
        ],
      ),
    );
  }
}
