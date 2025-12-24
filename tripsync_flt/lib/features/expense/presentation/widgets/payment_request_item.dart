import 'package:flutter/material.dart';

class PaymentRequestItem extends StatelessWidget {
  final String fromName;
  final String toName;
  final String amount;
  final bool isPaid;
  final VoidCallback? onPaidTap;

  const PaymentRequestItem({
    super.key,
    required this.fromName,
    required this.toName,
    required this.amount,
    this.isPaid = false,
    this.onPaidTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            fromName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            '→',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 15),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            toName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: onPaidTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C950),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Đã trả',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
