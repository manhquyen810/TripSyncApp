import 'package:flutter/material.dart';

class AddExpenseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AddExpenseButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF6A72821A).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '+ Thêm chi tiêu mới',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
