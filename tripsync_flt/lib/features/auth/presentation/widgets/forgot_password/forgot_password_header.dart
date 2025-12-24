import 'package:flutter/material.dart';

class ForgotPasswordHeader extends StatelessWidget {
  final String title;
  final String description;

  const ForgotPasswordHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1D1D),
            height: 1.33,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 1.43,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
