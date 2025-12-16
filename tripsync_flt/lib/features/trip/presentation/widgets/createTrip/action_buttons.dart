import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const ActionButtons({
    super.key,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(text: 'Hủy', onPressed: onCancel, isPrimary: false),
        const SizedBox(width: 28),
        _buildButton(text: 'Tạo', onPressed: onCreate, isPrimary: true),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: 145,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF00C950) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          side: isPrimary
              ? null
              : const BorderSide(color: Color(0xFFB2BBC6), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
