import 'package:flutter/material.dart';
import 'join_trip_icon.dart';

class JoinTripHeader extends StatelessWidget {
  const JoinTripHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const JoinTripIcon(),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Tham gia chuyến đi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Nhập mã mời để tham gia chuyến đi cùng bạn bè',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Color(0xFFA8B1BE),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
