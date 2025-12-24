import 'package:flutter/material.dart';

class AddFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddFloatingButton({
    super.key,
    this.onPressed,
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
      ),
    );
  }
}
