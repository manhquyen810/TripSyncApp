import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData? icon;
  final String? assetIconPath;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const BottomNavItem({
    super.key,
    this.icon,
    this.assetIconPath,
    required this.label,
    this.isActive = false,
    this.onTap,
  }) : assert(
         (icon != null) ^ (assetIconPath != null),
         'Provide exactly one of icon or assetIconPath',
       );

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isActive ? const Color(0xFF2D52CD) : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetIconPath != null)
            Image.asset(
              assetIconPath!,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              color: iconColor,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 32, height: 32);
              },
            )
          else
            Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
