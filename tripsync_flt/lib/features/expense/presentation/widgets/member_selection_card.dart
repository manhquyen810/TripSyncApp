import 'package:flutter/material.dart';

class MemberSelectionCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckIcon;

  const MemberSelectionCard({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.showCheckIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00C950) : const Color(0xFF99A1AF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckIcon && isSelected) ...[
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00C950),
                size: 24,
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
