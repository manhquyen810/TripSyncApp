import 'package:flutter/material.dart';
import '../../../../core/config/env.dart';

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
    final normalizedUrl = _normalizeMediaUrl(imageUrl);

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
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

  String? _normalizeMediaUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    if (trimmed.startsWith('assets/')) return trimmed;
    if (trimmed.startsWith('/')) return '${Env.apiBaseUrl}$trimmed';
    return '${Env.apiBaseUrl}/$trimmed';
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
