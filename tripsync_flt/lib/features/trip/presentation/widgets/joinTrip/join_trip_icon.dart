import 'package:flutter/material.dart';

class JoinTripIcon extends StatelessWidget {
  const JoinTripIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFA8E6CF).withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'images/trip/person.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
