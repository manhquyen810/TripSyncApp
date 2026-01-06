import 'package:flutter/material.dart';

class LoginTabBar extends StatelessWidget {
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  static const _selectedShadows = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6),
  ];

  const LoginTabBar({
    super.key,
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 161,
            child: GestureDetector(
              onTap: onLoginTap,
              child: Container(
                height: 47,
                decoration: BoxDecoration(
                  color: isLoginSelected
                      ? Colors.white
                      : const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  boxShadow: isLoginSelected ? _selectedShadows : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '\u0110\u0103ng nh\u1eadp',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 131,
            child: GestureDetector(
              onTap: onSignupTap,
              child: Container(
                height: 47,
                decoration: BoxDecoration(
                  color: !isLoginSelected
                      ? Colors.white
                      : const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  boxShadow: !isLoginSelected ? _selectedShadows : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '\u0110\u0103ng k\u00fd',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
