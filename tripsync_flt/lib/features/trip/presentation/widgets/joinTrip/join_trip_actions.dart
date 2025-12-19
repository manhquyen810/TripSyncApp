import 'package:flutter/material.dart';

class JoinTripActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onJoin;

  const JoinTripActions({
    super.key,
    required this.onCancel,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Cancel button
        SizedBox(
          width: 145,
          height: 40,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFB2BBC6)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Join button
        SizedBox(
          width: 145,
          height: 40,
          child: ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C950),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Tham gia',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
