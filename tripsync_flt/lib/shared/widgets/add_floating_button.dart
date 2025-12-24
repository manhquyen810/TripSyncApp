import 'package:flutter/material.dart';

class AddFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
import '../../features/expense/presentation/screens/add_expense_screen.dart';

class AddFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isExpenseScreen;

  const AddFloatingButton({
    super.key,
    this.onPressed,
    this.isExpenseScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: const Color(0xFF00C950),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        onPressed: () {
          if (isExpenseScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddExpenseScreen(),
              ),
            );
          } else if (onPressed != null) {
            onPressed!();
          }
        },
        backgroundColor: const Color(0xFF00C950),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
