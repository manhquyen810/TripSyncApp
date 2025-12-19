import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final EdgeInsetsGeometry padding;

  const HomeHeader({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Profile Icon
          InkWell(
            onTap: onProfileTap,
            child: Container(
              width: 56,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  'assets/icons/person.png',
                  width: 20,
                  height: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
