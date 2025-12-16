import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(22),
            color: Colors.black.withOpacity(0.2),
          ),
          child: const Text(
            "TripSync",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: width * 0.84,
          child: const Text(
            "Chào mừng bạn đến với TripSync! Cùng TripSync tạo nên những kỷ niệm đáng nhớ. Hãy bắt đầu lên kế hoạch cho chuyến phiêu lưu hoàn hảo.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.white,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}
