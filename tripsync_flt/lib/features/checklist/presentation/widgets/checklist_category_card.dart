import 'package:flutter/material.dart';

class ChecklistCategoryCard extends StatelessWidget {
	final ChecklistCategoryData data;
	final ValueChanged<int>? onItemTap;
	final ValueChanged<int>? onItemLongPress;
	final EdgeInsetsGeometry margin;

	const ChecklistCategoryCard({
		super.key,
		required this.data,
		this.onItemTap,
		this.onItemLongPress,
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
							padding: EdgeInsets.only(bottom: index == data.items.length - 1 ? 0 : 9),
							child: ChecklistItemRow(
								data: item,
								onTap: onItemTap == null ? null : () => onItemTap!.call(index),
								onLongPress: onItemLongPress == null ? null : () => onItemLongPress!.call(index),
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

	const ChecklistItemRow({
		super.key,
		required this.data,
		this.onTap,
		this.onLongPress,
	});

	@override
	Widget build(BuildContext context) {
		return InkWell(
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
							_AssigneeChip(name: data.assigneeName!),
						],
					],
				),
			),
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

	const _AssigneeChip({required this.name});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(12),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					SizedBox(
						width: 18,
						height: 18,
						child: Image.asset(
							'assets/icons/person.png',
							width: 18,
							height: 18,
							fit: BoxFit.contain,
							errorBuilder: (context, error, stackTrace) {
								return const Icon(Icons.person, size: 18, color: Colors.black);
							},
						),
					),
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
}

class ChecklistCategoryData {
	final String title;
	final List<ChecklistItemData> items;

	const ChecklistCategoryData({required this.title, required this.items});

	ChecklistCategoryData copyWith({String? title, List<ChecklistItemData>? items}) {
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

	const ChecklistItemData({
		this.id,
		required this.title,
		this.isChecked = false,
		this.assigneeId,
		this.assigneeName,
	});

	ChecklistItemData copyWith({int? id, String? title, bool? isChecked, int? assigneeId, String? assigneeName}) {
		return ChecklistItemData(
			id: id ?? this.id,
			title: title ?? this.title,
			isChecked: isChecked ?? this.isChecked,
			assigneeId: assigneeId ?? this.assigneeId,
			assigneeName: assigneeName ?? this.assigneeName,
		);
	}
}

