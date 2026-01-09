import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 1),
              left: BorderSide(color: Colors.white, width: 1),
              right: BorderSide(color: Colors.white, width: 1),
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(22)),
            color: Color(0x33000000),
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
        const SizedBox(
          width: double.infinity,
          child: Text(
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
