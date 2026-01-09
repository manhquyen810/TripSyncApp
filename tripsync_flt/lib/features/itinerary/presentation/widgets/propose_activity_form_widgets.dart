import 'package:flutter/material.dart';

import 'propose_activity_widgets.dart';

class ProposeActivityBody extends StatelessWidget {
  final Color green;
  final Color surface;
  final Color muted;
  final Color hint;

  final List<ProposeActivityType> types;
  final int selectedTypeIndex;
  final ValueChanged<int> onSelectType;

  final TextEditingController nameController;
  final FocusNode nameFocusNode;

  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode;

  final TextEditingController locationController;
  final FocusNode locationFocusNode;

  final String dateText;
  final bool isDatePlaceholder;
  final String timeText;
  final bool isTimePlaceholder;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onPickTime;

  final Future<void> Function() onPickLocation;
  final VoidCallback onCancel;
  final VoidCallback? onSubmit;

  const ProposeActivityBody({
    super.key,
    required this.green,
    required this.surface,
    required this.muted,
    required this.hint,
    required this.types,
    required this.selectedTypeIndex,
    required this.onSelectType,
    required this.nameController,
    required this.nameFocusNode,
    required this.descriptionController,
    required this.descriptionFocusNode,
    required this.locationController,
    required this.locationFocusNode,
    required this.dateText,
    required this.isDatePlaceholder,
    required this.timeText,
    required this.isTimePlaceholder,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPickLocation,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProposeActivityHeader(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loại hoạt động*',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 9),
                ProposeActivityTypeSelector(
                  green: green,
                  surface: surface,
                  types: types,
                  selectedIndex: selectedTypeIndex,
                  onSelect: onSelectType,
                ),
                const SizedBox(height: 36),
                ProposeActivityLabeledTextField(
                  label: 'Tên hoạt động *',
                  hintText: 'VD:Sapa- Xứ xở sương mù',
                  controller: nameController,
                  focusNode: nameFocusNode,
                  green: green,
                  muted: muted,
                  hintColor: hint,
                ),
                const SizedBox(height: 36),
                ProposeActivityLabeledTextField(
                  label: 'Mô tả *',
                  hintText: 'VD:Sapa- Xứ xở sương mù',
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  maxLines: 6,
                  minHeight: 117,
                  green: green,
                  muted: muted,
                  hintColor: hint,
                ),
                const SizedBox(height: 24),
                ProposeActivityLocationField(
                  controller: locationController,
                  focusNode: locationFocusNode,
                  green: green,
                  muted: muted,
                  hintColor: hint,
                  onMapTap: () => onPickLocation(),
                ),
                const SizedBox(height: 18),
                ProposeActivityDateTimeRow(
                  muted: muted,
                  hint: hint,
                  dateText: dateText,
                  isDatePlaceholder: isDatePlaceholder,
                  onPickDate: onPickDate,
                  timeText: timeText,
                  isTimePlaceholder: isTimePlaceholder,
                  onPickTime: onPickTime,
                ),
                const SizedBox(height: 24),
                ProposeActivityBottomButtons(
                  onCancel: onCancel,
                  onSubmit: onSubmit ?? () {},
                  green: green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProposeActivityDateTimeRow extends StatelessWidget {
  final Color muted;
  final Color hint;

  final String dateText;
  final bool isDatePlaceholder;
  final Future<void> Function() onPickDate;

  final String timeText;
  final bool isTimePlaceholder;
  final Future<void> Function() onPickTime;

  const ProposeActivityDateTimeRow({
    super.key,
    required this.muted,
    required this.hint,
    required this.dateText,
    required this.isDatePlaceholder,
    required this.onPickDate,
    required this.timeText,
    required this.isTimePlaceholder,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProposeActivityPickerField(
            muted: muted,
            hint: hint,
            label: 'Ngày *',
            labelIcon: Icons.calendar_month_outlined,
            value: dateText,
            isPlaceholder: isDatePlaceholder,
            trailingIcon: Icons.calendar_month_outlined,
            onTap: () => onPickDate(),
          ),
        ),
        const SizedBox(width: 19),
        Expanded(
          child: ProposeActivityPickerField(
            muted: muted,
            hint: hint,
            label: 'Giờ *',
            labelIcon: Icons.access_time,
            value: timeText,
            isPlaceholder: isTimePlaceholder,
            trailingIcon: Icons.access_time,
            onTap: () => onPickTime(),
          ),
        ),
      ],
    );
  }
}

class ProposeActivityPickerField extends StatelessWidget {
  final Color muted;
  final Color hint;
  final String label;
  final IconData labelIcon;
  final String value;
  final bool isPlaceholder;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const ProposeActivityPickerField({
    super.key,
    required this.muted,
    required this.hint,
    required this.label,
    required this.labelIcon,
    required this.value,
    required this.isPlaceholder,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(labelIcon, size: 24, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: muted.withAlpha(77), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: isPlaceholder ? hint : Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(trailingIcon, size: 20, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
