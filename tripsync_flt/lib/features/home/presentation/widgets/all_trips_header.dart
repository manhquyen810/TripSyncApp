import 'package:flutter/material.dart';

class AllTripsHeader extends StatelessWidget {
  final VoidCallback? onCreateTripTap;

  const AllTripsHeader({
    super.key,
    this.onCreateTripTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/plane.png',
                width: 16,
                height: 16,
                color: Colors.black,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.flight_takeoff,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          const Text(
            'Chuyến đi của bạn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Poppins',
              height: 1.0,
            ),
          ),

          const SizedBox(height: 4),

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

          const SizedBox(height: 12),

          // Create Trip Button
          InkWell(
            onTap: onCreateTripTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C950),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '+',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Tạo chuyến đi mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
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
