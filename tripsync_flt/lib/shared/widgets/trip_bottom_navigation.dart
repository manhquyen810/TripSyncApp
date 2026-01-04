import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';
import '../../routes/app_routes.dart';
import '../../features/trip/domain/entities/trip.dart';

class TripBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Trip? trip;
  final Function(int)? onTap;

  const TripBottomNavigation({
    super.key,
    this.currentIndex = 0,
    this.trip,
    this.onTap,
  });

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
              onTap: () => _handleTap(context, 0),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/document.png',
              label: 'Upload',
              isActive: currentIndex == 1,
              onTap: () => _handleTap(context, 1),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/coin.png',
              label: 'Chi tiêu',
              isActive: currentIndex == 2,
              onTap: () => _handleTap(context, 2),
            ),
          ),
          Expanded(
            child: BottomNavItem(
              assetIconPath: 'assets/icons/list.png',
              label: 'Checklist',
              isActive: currentIndex == 3,
              onTap: () => _handleTap(context, 3),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!.call(index);
      return;
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final Trip? tripArg = trip ?? (routeArgs is Trip ? routeArgs : null);

    void showNotReady(String label) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Màn hình "$label" chưa được tạo.')),
      );
    }

    void goTo(String routeName, {Object? arguments}) {
      final currentRouteName = ModalRoute.of(context)?.settings.name;
      if (currentRouteName == routeName) {
        return;
      }

      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }

    switch (index) {
      case 0:
        if (tripArg != null) {
          goTo(AppRoutes.itinerary, arguments: tripArg);
        } else {
          goTo(AppRoutes.home);
        }
        return;
      case 1:
        if (tripArg != null) {
          goTo(AppRoutes.documents, arguments: tripArg);
        } else {
          goTo(AppRoutes.home);
        }
        return;
      case 2:
        if (tripArg != null) {
          goTo(AppRoutes.expense, arguments: tripArg);
        } else {
          showNotReady('Chi tiêu');
        }
        return;
      case 3:
        if (tripArg != null) {
          goTo(AppRoutes.checklist, arguments: tripArg);
        } else {
          showNotReady('Checklist');
        }
        return;
    }
  }
}
