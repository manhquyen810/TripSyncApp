import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../styles/app_colors.dart';

class AddFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? routeName;
  final Object? routeArguments;
  final EdgeInsetsGeometry padding;

  const AddFloatingButton({
    super.key,
    this.onPressed,
    this.routeName,
    this.routeArguments,
    this.padding = const EdgeInsets.only(bottom: 80),
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed =
        onPressed ??
        (routeName != null
            ? () => Navigator.pushNamed(
                context,
                routeName!,
                arguments: routeArguments,
              )
            : null);

    return Padding(
      padding: padding,
      child: FloatingActionButton(
        onPressed: effectiveOnPressed,
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}
