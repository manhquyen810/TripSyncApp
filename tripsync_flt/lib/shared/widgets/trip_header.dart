import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../styles/app_colors.dart';
import '../../routes/app_routes.dart';

class TripHeader extends StatelessWidget {
  final String title;
  final String location;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSettingsPressed;

  const TripHeader({
    super.key,
    required this.title,
    required this.location,
    this.onBackPressed,
    this.onSettingsPressed,
  });

  void _navigateBackToHome(BuildContext context) {
    final navigator = Navigator.of(context);

    var foundHome = false;
    navigator.popUntil((route) {
      if (route.settings.name == AppRoutes.home) {
        foundHome = true;
        return true;
      }
      return false;
    });

    if (!foundHome) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => _navigateBackToHome(context),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.buttonBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.arrowLeft, size: 24),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/location.png',
                      width: 16,
                      height: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}
