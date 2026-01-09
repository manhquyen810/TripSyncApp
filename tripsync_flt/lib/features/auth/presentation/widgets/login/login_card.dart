import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final Widget child;

  const LoginCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width < 360 ? 16 : 24;
    final double verticalPadding = screenSize.height < 720 ? 20 : 24;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: child,
      ),
    );
  }
}
