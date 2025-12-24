import 'package:flutter/material.dart';

class BalanceItem extends StatelessWidget {
  final String name;
  final String amount;
  final bool isPositive;

  const BalanceItem({
    super.key,
    required this.name,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.person,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: isPositive ? const Color(0xFF00C950) : const Color(0xFFDF1F32),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          color: Colors.grey[300],
        ),
      ],
    );
  }
}
