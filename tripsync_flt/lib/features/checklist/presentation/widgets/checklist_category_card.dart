import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';

class ChecklistCategoryCard extends StatelessWidget {
  final ChecklistCategoryData data;
  final ValueChanged<int>? onItemTap;
  final ValueChanged<int>? onItemLongPress;
  final Future<bool> Function(int itemIndex)? onConfirmDelete;
  final ValueChanged<int>? onDelete;
  final EdgeInsetsGeometry margin;

  const ChecklistCategoryCard({
    super.key,
    required this.data,
    this.onItemTap,
    this.onItemLongPress,
    this.onConfirmDelete,
    this.onDelete,
    this.margin = const EdgeInsets.symmetric(horizontal: 15),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          ...data.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == data.items.length - 1 ? 0 : 9,
              ),
              child: ChecklistItemRow(
                data: item,
                onTap: onItemTap == null ? null : () => onItemTap!.call(index),
                onLongPress: onItemLongPress == null
                    ? null
                    : () => onItemLongPress!.call(index),
                onConfirmDelete: onConfirmDelete == null
                    ? null
                    : () => onConfirmDelete!.call(index),
                onDelete: onDelete == null ? null : () => onDelete!.call(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ChecklistItemRow extends StatelessWidget {
  final ChecklistItemData data;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Future<bool> Function()? onConfirmDelete;
  final VoidCallback? onDelete;

  const ChecklistItemRow({
    super.key,
    required this.data,
    this.onTap,
    this.onLongPress,
    this.onConfirmDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _ChecklistCheckbox(isChecked: data.isChecked),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  decoration: data.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.assigneeName != null) ...[
              const SizedBox(width: 10),
              _AssigneeChip(
                name: data.assigneeName!,
                avatarUrl: data.assigneeAvatarUrl,
              ),
            ],
          ],
        ),
      ),
    );

    final canSwipeDelete =
        onConfirmDelete != null && onDelete != null && data.id != null;
    if (!canSwipeDelete) return content;

    return Dismissible(
      key: ValueKey<String>('checklist-item-${data.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction != DismissDirection.endToStart) return false;
        return onConfirmDelete!.call();
      },
      onDismissed: (_) => onDelete!.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: content,
    );
  }
}

class _ChecklistCheckbox extends StatelessWidget {
  final bool isChecked;

  const _ChecklistCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00C950), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 16, color: Color(0xFF00C950))
          : null,
    );
  }
}

class _AssigneeChip extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _AssigneeChip({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final url = avatarUrl?.trim();
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackAvatar();
                },
              )
            : _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Center(
      child: Image.asset(
        'assets/icons/person.png',
        width: 14,
        height: 14,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 14, color: Colors.black);
        },
      ),
    );
  }
}

class ChecklistCategoryData {
  final String title;
  final List<ChecklistItemData> items;

  const ChecklistCategoryData({required this.title, required this.items});

  ChecklistCategoryData copyWith({
    String? title,
    List<ChecklistItemData>? items,
  }) {
    return ChecklistCategoryData(
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }
}

class ChecklistItemData {
  final int? id;
  final String title;
  final bool isChecked;
  final int? assigneeId;
  final String? assigneeName;
  final String? assigneeAvatarUrl;

  const ChecklistItemData({
    this.id,
    required this.title,
    this.isChecked = false,
    this.assigneeId,
    this.assigneeName,
    this.assigneeAvatarUrl,
  });

  ChecklistItemData copyWith({
    int? id,
    String? title,
    bool? isChecked,
    int? assigneeId,
    String? assigneeName,
    String? assigneeAvatarUrl,
  }) {
    return ChecklistItemData(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatarUrl: assigneeAvatarUrl ?? this.assigneeAvatarUrl,
    );
  }
}
