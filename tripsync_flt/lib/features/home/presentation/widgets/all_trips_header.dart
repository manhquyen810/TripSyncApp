import 'package:flutter/material.dart';

class AllTripsHeader extends StatelessWidget {
  final VoidCallback? onCreateTripTap;

  const AllTripsHeader({super.key, this.onCreateTripTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Chuyến đi của bạn',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Poppins',
              height: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          // Description
          const Text(
            'Quản lý thời gian và theo dõi chuyến đi của bạn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF959DA3),
              fontFamily: 'Poppins',
              height: 1.43,
            ),
          ),

          const SizedBox(height: 16),

          // Create Trip Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onCreateTripTap,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tạo chuyến đi mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C950),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
