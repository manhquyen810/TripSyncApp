import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'member_avatar.dart';

class TripCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final int memberCount;
  final List<String> memberAvatarUrls;
  final List<Color> memberColors;
  final VoidCallback? onTap;
  final double cardWidth;
  final double imageHeight;

  const TripCard({
    super.key,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.memberCount,
    this.memberAvatarUrls = const [],
    this.memberColors = const [],
    this.onTap,
    this.cardWidth = 320,
    this.imageHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: imageHeight,
                child: Stack(
                  children: [
                    _buildCoverImage(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: imageHeight * 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(153),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/location.png',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Image.asset('assets/icons/group.png', width: 24, height: 24),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$memberCount thành viên',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(children: _buildMemberAvatars()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMemberAvatars() {
    final normalizedAvatarUrls = memberAvatarUrls
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final avatars = <Widget>[];
    final maxShown = 3;
    final effectiveMemberCount = memberCount < 0 ? 0 : memberCount;

    if (normalizedAvatarUrls.isNotEmpty) {
      var shownCount = maxShown;
      if (effectiveMemberCount < shownCount) shownCount = effectiveMemberCount;
      if (normalizedAvatarUrls.length < shownCount) {
        shownCount = normalizedAvatarUrls.length;
      }

      final shownUrls = normalizedAvatarUrls
          .take(shownCount)
          .toList(growable: false);
      for (final url in shownUrls) {
        avatars.add(MemberAvatar(color: Colors.grey.shade300, imageUrl: url));
      }

      final overflow = effectiveMemberCount - shownUrls.length;
      if (overflow > 0) {
        avatars.add(_buildOverflowAvatar(overflow));
      }

      return avatars;
    }

    var shownCount = maxShown;
    if (effectiveMemberCount < shownCount) shownCount = effectiveMemberCount;
    if (memberColors.length < shownCount) shownCount = memberColors.length;

    final shownColors = memberColors.take(shownCount).toList(growable: false);
    for (final color in shownColors) {
      avatars.add(MemberAvatar(color: color));
    }

    final overflow = effectiveMemberCount - shownColors.length;
    if (overflow > 0) {
      avatars.add(_buildOverflowAvatar(overflow));
    }

    return avatars;
  }

  Widget _buildOverflowAvatar(int overflow) {
    return Container(
      width: 25,
      height: 25,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade500,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(230), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$overflow',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _buildCoverImage() {
    final url = _coerceCoverUrl(imageUrl);
    final placeholder = Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(LucideIcons.image, size: 50),
    );

    if (url.isEmpty) {
      return SizedBox(
        width: cardWidth,
        height: imageHeight,
        child: placeholder,
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: cardWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: cardWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    if (kIsWeb) {
      return SizedBox(
        width: cardWidth,
        height: imageHeight,
        child: placeholder,
      );
    }

    return Image.file(
      File(url),
      width: cardWidth,
      height: imageHeight,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  String _coerceCoverUrl(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return value;

    // Some buggy call paths can end up with an encoded URL being treated like an
    // asset path on web (e.g. "assets/https%253A//...").
    if (value.startsWith('assets/')) {
      final rest = value.substring('assets/'.length);
      if (_looksLikeEncodedHttpUrl(rest)) {
        value = rest;
      }
    }

    // Decode percent-encoded URLs (sometimes double-encoded).
    for (var i = 0; i < 2; i++) {
      if (!_looksLikeEncodedHttpUrl(value)) break;
      try {
        value = Uri.decodeFull(value).trim();
      } catch (_) {
        break;
      }
    }

    return value;
  }

  bool _looksLikeEncodedHttpUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http%3a') ||
        lower.startsWith('https%3a') ||
        lower.startsWith('http%253a') ||
        lower.startsWith('https%253a');
  }
}
