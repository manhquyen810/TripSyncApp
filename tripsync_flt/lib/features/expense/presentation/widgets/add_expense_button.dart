import 'package:flutter/material.dart';
import '../screens/add_expense_screen.dart';

class AddExpenseButton extends StatelessWidget {
  const AddExpenseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddExpenseScreen(),
          ),
        );
      },
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
