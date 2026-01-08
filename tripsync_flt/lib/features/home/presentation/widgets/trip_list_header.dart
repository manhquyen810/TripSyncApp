import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TripListHeader extends StatelessWidget {
  final int activeTripCount;
  final VoidCallback? onViewAllTap;
  final EdgeInsetsGeometry padding;

  const TripListHeader({
    super.key,
    required this.activeTripCount,
    this.onViewAllTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00C950);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chuyến đi của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.circle, size: 10, color: activeColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$activeTripCount chuyến đi đang hoạt động',
                        style: const TextStyle(
                          fontSize: 13,
                          color: activeColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
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
          const SizedBox(width: 12),
          InkWell(
            onTap: onViewAllTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Tất cả',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 14, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
