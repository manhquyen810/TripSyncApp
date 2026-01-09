import 'package:flutter/material.dart';
import 'feature_button.dart';

class FavoriteFeaturesSection extends StatelessWidget {
  final VoidCallback? onJoinTripTap;
  final VoidCallback? onCreateTripTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final EdgeInsetsGeometry padding;

  const FavoriteFeaturesSection({
    super.key,
    this.onJoinTripTap,
    this.onCreateTripTap,
    this.onProfileTap,
    this.onSettingsTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 17),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minButtonWidth = 88.0;
          const maxButtonWidth = 120.0;
          const spacing = 16.0;
          const runSpacing = 16.0;

          final maxColumns = (constraints.maxWidth / (minButtonWidth + spacing))
              .floor()
              .clamp(1, 4);
          final computedWidth =
              (constraints.maxWidth - (spacing * (maxColumns - 1))) /
              maxColumns;
          final buttonWidth = computedWidth.clamp(
            minButtonWidth,
            maxButtonWidth,
          );

          final buttons = [
            FeatureButton(
              label: 'Tham gia chuyến đi',
              icon: Icons.group_add,
              onTap: onJoinTripTap,
              width: buttonWidth,
            ),
            FeatureButton(
              label: 'Tạo chuyến đi',
              icon: Icons.add_circle_outline,
              onTap: onCreateTripTap,
              width: buttonWidth,
            ),
            FeatureButton(
              label: 'Hồ sơ',
              icon: Icons.person,
              assetIconPath: 'assets/icons/person.png',
              onTap: onProfileTap,
              width: buttonWidth,
            ),
            FeatureButton(
              label: 'Cài đặt',
              icon: Icons.settings,
              onTap: onSettingsTap,
              width: buttonWidth,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chức năng ưa thích',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: buttons,
              ),
            ],
          );
        },
      ),
    );
  }
}
