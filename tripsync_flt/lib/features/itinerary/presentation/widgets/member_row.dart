import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/styles/app_colors.dart';

class MemberRowModel {
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final Color fallbackColor;
  final bool isLeader;
  final String? roleBadgeText;
  final bool? isActive;

  const MemberRowModel({
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.fallbackColor,
    required this.isLeader,
    this.roleBadgeText,
    this.isActive,
  });
}

class MemberRow extends StatelessWidget {
  final MemberRowModel model;

  const MemberRow({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    const leaderAccent = Color(0xFFFFB74D);

    final isLeader = model.isLeader;

    return Container(
      padding: EdgeInsets.fromLTRB(isLeader ? 16 : 13, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: isLeader
            ? const Border(left: BorderSide(color: leaderAccent, width: 4))
            : null,
      ),
      child: Row(
        children: [
          _LargeAvatar(
            imageUrl: model.avatarUrl,
            color: model.fallbackColor,
            isLeader: model.isLeader,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (model.roleBadgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: leaderAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          model.roleBadgeText!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: leaderAccent,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (model.subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    model.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (model.isActive != null) ...[
            _StatusDot(isActive: model.isActive!, isLeader: model.isLeader),
            const SizedBox(width: 8),
          ],
          _ActionButton(icon: isLeader ? LucideIcons.pencil : LucideIcons.moreVertical),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;
  final bool isLeader;

  const _StatusDot({required this.isActive, required this.isLeader});

  @override
  Widget build(BuildContext context) {
    const leaderAccent = Color(0xFFFFB74D);
    final dot = isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isLeader
                ? Border.all(color: leaderAccent, width: 2)
                : Border.all(color: Colors.transparent, width: 0),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  final String? imageUrl;
  final Color color;
  final bool isLeader;

  const _LargeAvatar({
    required this.imageUrl,
    required this.color,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    const leaderAccent = Color(0xFFFFB74D);

    final avatar = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isLeader ? Colors.white : const Color(0xFFF3F4F6),
          width: isLeader ? 2 : 1,
        ),
        boxShadow: isLeader
            ? const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _AvatarImageOrFallback(imageUrl: imageUrl, color: color),
    );

    if (!isLeader) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: leaderAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(LucideIcons.star, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AvatarImageOrFallback extends StatelessWidget {
  final String? imageUrl;
  final Color color;

  const _AvatarImageOrFallback({required this.imageUrl, required this.color});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    Widget fallback() {
      final brightness = ThemeData.estimateBrightnessForColor(color);
      final iconColor = brightness == Brightness.dark
          ? Colors.white
          : AppColors.textPrimary;

      return Container(
        color: color,
        alignment: Alignment.center,
        child: Icon(LucideIcons.user, color: iconColor, size: 22),
      );
    }

    if (url == null || url.isEmpty) {
      return fallback();
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;

  const _ActionButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 22, color: AppColors.textPrimary),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
