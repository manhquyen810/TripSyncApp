import 'package:flutter/material.dart';

class TotalExpenseCard extends StatelessWidget {
  final String totalAmount;
  final String owedAmount;
  final bool isPositiveBalance;
  final VoidCallback? onDetailTap;

  const TotalExpenseCard({
    super.key,
    required this.totalAmount,
    required this.owedAmount,
    this.isPositiveBalance = false,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B91A8),
            Color(0xFF4CA5E0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng chi tiêu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 34),
          Text(
            totalAmount,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              Expanded(
                child: Text(
                  isPositiveBalance
                      ? 'Nhóm đang nợ bạn: $owedAmount'
                      : 'Bạn đang nợ nhóm: $owedAmount',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (onDetailTap != null)
                GestureDetector(
                  onTap: onDetailTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
