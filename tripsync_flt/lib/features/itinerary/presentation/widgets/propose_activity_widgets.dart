import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProposeActivityType {
  final String label;
  final IconData icon;

  const ProposeActivityType({required this.label, required this.icon});
}

class ProposeActivityHeader extends StatelessWidget {
  final VoidCallback onBack;

  const ProposeActivityHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 51,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.arrowLeft, size: 24),
                ),
              ),
            ),
            const Text(
              'Đề xuất hoạt động',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProposeActivityTypeSelector extends StatelessWidget {
  final List<ProposeActivityType> types;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color green;
  final Color surface;

  const ProposeActivityTypeSelector({
    super.key,
    required this.types,
    required this.selectedIndex,
    required this.onSelect,
    required this.green,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(types.length, (index) {
            final isSelected = index == selectedIndex;
            final type = types[index];

            return Padding(
              padding: EdgeInsets.only(
                right: index == types.length - 1 ? 0 : 5,
              ),
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  width: 78,
                  height: 84,
                  decoration: BoxDecoration(
                    color: isSelected ? green : surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8C8C8).withAlpha(77),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Icon(type.icon, size: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 20 / 12,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ProposeActivityLabeledTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLines;
  final double? minHeight;
  final Color green;
  final Color muted;
  final Color hintColor;

  const ProposeActivityLabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.green,
    required this.muted,
    required this.hintColor,
    this.maxLines = 1,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, _) {
            final borderColor = focusNode.hasFocus
                ? green
                : muted.withAlpha(77);

            return Container(
              constraints: minHeight == null
                  ? null
                  : BoxConstraints(minHeight: minHeight!),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: hintColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProposeActivityLocationField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color green;
  final Color muted;
  final Color hintColor;
  final VoidCallback? onMapTap;

  const ProposeActivityLocationField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.green,
    required this.muted,
    required this.hintColor,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.mapPin, size: 24, color: Colors.black),
            SizedBox(width: 4),
            Text(
              'Địa điểm *',
              style: TextStyle(
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
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, _) {
            final borderColor = focusNode.hasFocus
                ? green
                : muted.withAlpha(77);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'VD:Sapa- Xứ xở sương mù',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: hintColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onMapTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          LucideIcons.map,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProposeActivityBottomButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final Color green;

  const ProposeActivityBottomButtons({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    required this.green,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 40,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 170,
          height: 40,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.plus, size: 18, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Đề xuất',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
