import 'package:flutter/material.dart';

class InviteCodeInput extends StatelessWidget {
  final TextEditingController controller;

  const InviteCodeInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mã mời',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        // Input field
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập mã mời (VD: 123456)',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFA8B1BE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFA8B1BE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C950), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Helper text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Bạn có thể nhận mã mời từ người tạo chuyến đi hoặc các thành viên khác trong nhóm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
