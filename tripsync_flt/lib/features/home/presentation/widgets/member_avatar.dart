import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final Color color;
  final String? imageUrl;
  final double size;

  const MemberAvatar({
    super.key,
    required this.color,
    this.imageUrl,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white, size: 15),
              ),
            )
          : const Icon(Icons.person, color: Colors.white, size: 15),
    );
  }
}
