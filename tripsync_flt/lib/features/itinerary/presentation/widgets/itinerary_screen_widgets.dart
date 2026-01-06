part of '../screens/itinerary_screen.dart';

class _ItineraryStatsSection extends StatelessWidget {
  final Future<_DayActivities> future;
  final int dayNumber;

  const _ItineraryStatsSection({required this.future, required this.dayNumber});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DayActivities>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final confirmedCount = data?.confirmed.length ?? 0;
        final proposedCount = data?.proposed.length ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ItineraryStatColumn(
                    label: 'Ngày',
                    value: '$dayNumber',
                    labelColor: AppColors.textSecondary,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                Expanded(
                  child: _ItineraryStatColumn(
                    label: 'Chốt',
                    value: '$confirmedCount',
                    labelColor: AppColors.primary,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                Expanded(
                  child: _ItineraryStatColumn(
                    label: 'Đề xuất',
                    value: '$proposedCount',
                    labelColor: const Color(0xFFF87171),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItineraryStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;

  const _ItineraryStatColumn({
    required this.label,
    required this.value,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ItineraryDaySelector extends StatelessWidget {
  final List<Map<String, String>> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ItineraryDaySelector({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(days.length, (index) {
            final isSelected = index == selectedIndex;
            final day = days[index];

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => onSelected(index),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 80),
                      padding: EdgeInsets.symmetric(
                        vertical: isSelected ? 14 : 13,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day['label'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day['date'] ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ItinerarySections extends StatelessWidget {
  final int? tripId;
  final Future<_DayActivities> future;
  final int memberCount;
  final _IsBusyFn isBusy;
  final _VoteRatioTextFn ratioText;
  final _VoteFn onVote;
  final _ConfirmFn onConfirm;
  final _EditLocationFn onEditLocation;

  const _ItinerarySections({
    required this.tripId,
    required this.future,
    required this.memberCount,
    required this.isBusy,
    required this.ratioText,
    required this.onVote,
    required this.onConfirm,
    required this.onEditLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (tripId == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ItinerarySectionHeader(
              icon: Icons.check_circle_outline,
              title: 'Đã chốt (0)',
              color: AppColors.primary,
            ),
            SizedBox(height: 12),
            _ItineraryEmptySectionText(),
            SizedBox(height: 8),
            _ItinerarySectionHeader(
              icon: Icons.lightbulb_outline,
              title: 'Đề xuất (0)',
              color: Color(0xFFFFB74D),
            ),
            SizedBox(height: 12),
            _ItineraryEmptySectionText(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<_DayActivities>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return const _ItineraryActivitiesLoadError();
          }

          final data = snapshot.data ?? const _DayActivities.empty();
          final confirmed = data.confirmed;
          final proposed = data.proposed;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItinerarySectionHeader(
                icon: Icons.check_circle_outline,
                title: 'Đã chốt (${confirmed.length})',
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              if (confirmed.isEmpty)
                const _ItineraryEmptySectionText()
              else
                ...confirmed.map((a) {
                  final descriptionSubtitle = a.description.trim().isNotEmpty
                      ? a.description
                      : a.subtitle;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ConfirmedActivityCard(
                      title: a.title,
                      category: a.category,
                      subtitle: descriptionSubtitle,
                      time: a.timeText,
                      location: a.location,
                      likes: a.likesText,
                      proposedBy: a.proposedBy,
                    ),
                  );
                }),
              const SizedBox(height: 8),
              _ItinerarySectionHeader(
                icon: Icons.lightbulb_outline,
                title: 'Đề xuất (${proposed.length})',
                color: const Color(0xFFFFB74D),
              ),
              const SizedBox(height: 12),
              if (proposed.isEmpty)
                const _ItineraryEmptySectionText()
              else
                ...proposed.map((a) {
                  final id = a.id;
                  final descriptionSubtitle = a.description.trim().isNotEmpty
                      ? a.description
                      : a.subtitle;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ProposedActivityCard(
                      title: a.title,
                      category: a.category,
                      subtitle: descriptionSubtitle,
                      timeRange: a.timeText,
                      location: a.location,
                      ratioText: ratioText(a),
                      myVote: a.myVote,
                      isBusy: id != null && isBusy(id),
                      onUpvote: (id == null)
                          ? null
                          : () => onVote(id, 'upvote'),
                      onDownvote: (id == null)
                          ? null
                          : () => onVote(id, 'downvote'),
                      onConfirm: (id == null) ? null : () => onConfirm(id),
                      onLongPress: (id == null)
                          ? null
                          : () => onEditLocation(a),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _ItineraryEmptySectionText extends StatelessWidget {
  const _ItineraryEmptySectionText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        'Chưa có hoạt động nào',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ItineraryActivitiesLoadError extends StatelessWidget {
  const _ItineraryActivitiesLoadError();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Chưa thể tải hoạt động.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ItinerarySectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ItinerarySectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }
}

class _ConfirmedActivityCard extends StatelessWidget {
  final String title;
  final String category;
  final String subtitle;
  final String time;
  final String location;
  final String likes;
  final String proposedBy;

  const _ConfirmedActivityCard({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.time,
    required this.location,
    required this.likes,
    required this.proposedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (category.trim().isNotEmpty) ...[
                    _CategoryChip(
                      label: category,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                proposedBy,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  _SmallUserAvatar(color: AppColors.buttonBackground),
                  SizedBox(width: 8),
                  _SmallUserAvatar(color: AppColors.iconBackground),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallUserAvatar extends StatelessWidget {
  final Color color;

  const _SmallUserAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _CategoryChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ProposedActivityCard extends StatelessWidget {
  final String title;
  final String category;
  final String subtitle;
  final String timeRange;
  final String location;
  final String ratioText;
  final String? myVote;
  final bool isBusy;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onConfirm;
  final VoidCallback? onLongPress;

  const _ProposedActivityCard({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.timeRange,
    required this.location,
    required this.ratioText,
    required this.myVote,
    required this.isBusy,
    required this.onUpvote,
    required this.onDownvote,
    required this.onConfirm,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFB74D);

    return GestureDetector(
      onLongPress: isBusy ? null : onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          border: const Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          timeRange,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.trim().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: category,
                          backgroundColor: accent.withValues(alpha: 0.10),
                          textColor: accent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: const Color(0xFFF3F4F6)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _VoteButton(
                            icon: Icons.thumb_up_outlined,
                            iconColor: myVote == 'upvote'
                                ? AppColors.blue
                                : AppColors.textSecondary,
                            onTap: isBusy ? null : onUpvote,
                          ),
                          const SizedBox(width: 8),
                          _VoteButton(
                            icon: Icons.thumb_down_outlined,
                            iconColor: myVote == 'downvote'
                                ? AppColors.danger
                                : AppColors.textSecondary,
                            onTap: isBusy ? null : onDownvote,
                          ),
                        ],
                      ),
                      Text(
                        ratioText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isBusy ? null : onConfirm,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Chờ duyệt',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _VoteButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
