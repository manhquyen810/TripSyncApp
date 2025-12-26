import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageAsset;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  final bool showCameraBadge;

  const ProfileAvatar({
    super.key,
    required this.imageAsset,
    required this.imageBytes,
    this.onTap,
    this.showCameraBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 82,
      height: 82,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: ClipOval(
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: AppColors.buttonBackground,
                    child: Center(child: Icon(Icons.person, size: 32)),
                  );
                },
              )
            : Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: AppColors.buttonBackground,
                    child: Center(child: Icon(Icons.person, size: 32)),
                  );
                },
              ),
      ),
    );

    final withOptionalTap = onTap == null
        ? avatar
        : GestureDetector(onTap: onTap, child: avatar);

    if (!showCameraBadge) {
      return withOptionalTap;
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        withOptionalTap,
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(right: 4, bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 14,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
