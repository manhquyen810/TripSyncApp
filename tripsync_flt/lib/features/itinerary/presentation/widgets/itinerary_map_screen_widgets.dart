part of '../screens/itinerary_map_screen.dart';

class _HeaderBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onSearch;

  const _HeaderBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendChips extends StatelessWidget {
  final int confirmedCount;
  final int proposedCount;

  const _LegendChips({
    required this.confirmedCount,
    required this.proposedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _LegendChip(
            dotColor: AppColors.primary,
            borderColor: AppColors.primary.withValues(alpha: 0.20),
            textColor: AppColors.primary,
            label: 'Đã chốt ($confirmedCount)',
          ),
          const SizedBox(width: 8),
          _LegendChip(
            dotColor: AppColors.accent,
            borderColor: AppColors.accent.withValues(alpha: 0.20),
            textColor: AppColors.accent,
            label: 'Đề xuất ($proposedCount)',
          ),
        ],
      ),
    );
  }
}

class _DayFilterDropdown extends StatelessWidget {
  final int daysCount;
  final int? value; // null = all
  final ValueChanged<int?> onChanged;

  const _DayFilterDropdown({
    required this.daysCount,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text(
          'Tất cả ngày',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      ...List<DropdownMenuItem<int?>>.generate(max(0, daysCount), (i) {
        final day = i + 1;
        return DropdownMenuItem<int?>(
          value: day,
          child: Text(
            'Ngày $day',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        );
      }, growable: false),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onChanged: onChanged,
              items: items,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color dotColor;
  final Color borderColor;
  final Color textColor;
  final String label;

  const _LegendChip({
    required this.dotColor,
    required this.borderColor,
    required this.textColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onLocate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _MapControls({
    required this.onLocate,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onLocate,
            icon: const Icon(Icons.my_location, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ControlButton(
                icon: Icons.add,
                showDivider: true,
                onPressed: onZoomIn,
              ),
              _ControlButton(
                icon: Icons.remove,
                showDivider: false,
                onPressed: onZoomOut,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool showDivider;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.showDivider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _MarkerPopupLayer extends StatelessWidget {
  final _ActivityItem activity;
  final Offset? anchorPx;

  const _MarkerPopupLayer({required this.activity, required this.anchorPx});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final padding = media.padding;

    final anchor = anchorPx ?? Offset(size.width / 2, size.height / 2);

    const double popupWidth = 220;
    const double tailHeight = 16;
    const double popupTopMargin = 8;

    final left = (anchor.dx - popupWidth / 2).clamp(
      16.0,
      size.width - 16.0 - popupWidth,
    );

    // Try to place above the marker, but don't let it go under the header.
    final minTop = padding.top + 90;
    final desiredTop = anchor.dy - 108;
    final top = desiredTop.clamp(minTop, size.height - 200.0);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top + popupTopMargin,
          width: popupWidth,
          child: _MarkerPopup(activity: activity),
        ),
        // Tail (diamond) roughly pointing to the anchor.
        Positioned(
          left: (anchor.dx - tailHeight / 2).clamp(16.0, size.width - 16.0),
          top: (top + popupTopMargin + 86).clamp(0.0, size.height - 16.0),
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: tailHeight,
              height: tailHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerPopup extends StatelessWidget {
  final _ActivityItem activity;

  const _MarkerPopup({required this.activity});

  @override
  Widget build(BuildContext context) {
    final accent = activity.isConfirmed ? AppColors.primary : AppColors.accent;
    final showProposedBy =
        !activity.isConfirmed && activity.proposedBy.isNotEmpty;

    IconData categoryIcon(String raw) {
      final s = raw.trim().toLowerCase();
      if (s.isEmpty) return Icons.local_activity_outlined;
      if (s.contains('ăn') ||
          s.contains('food') ||
          s.contains('cafe') ||
          s.contains('restaurant')) {
        return Icons.restaurant_outlined;
      }
      if (s.contains('khách sạn') || s.contains('hotel')) {
        return Icons.apartment_outlined;
      }
      if (s.contains('tham quan') ||
          s.contains('sight') ||
          s.contains('tour') ||
          s.contains('visit')) {
        return Icons.photo_camera_outlined;
      }
      if (s.contains('di chuyển') ||
          s.contains('transport') ||
          s.contains('move') ||
          s.contains('car')) {
        return Icons.directions_car_filled_outlined;
      }
      return Icons.local_activity_outlined;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            activity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(categoryIcon(activity.category), size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          if (showProposedBy) ...[
            const SizedBox(height: 2),
            Text(
              'Đề xuất bởi ${activity.proposedBy}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.accent,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
