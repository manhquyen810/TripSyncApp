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
    final normalizedUrl = imageUrl?.trim();

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(230), width: 2),
      ),
      child: (normalizedUrl != null && normalizedUrl.isNotEmpty)
          ? ClipOval(child: _buildImage(normalizedUrl))
          : _buildFallbackIcon(),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Image.asset(
        'assets/icons/person.png',
        width: 15,
        height: 15,
        color: Colors.white,
      ),
    );
  }
}
