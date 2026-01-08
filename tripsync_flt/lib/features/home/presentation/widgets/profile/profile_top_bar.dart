import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ProfileTopBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
