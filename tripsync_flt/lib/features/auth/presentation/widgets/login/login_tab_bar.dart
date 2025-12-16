import 'package:flutter/material.dart';

class LoginTabBar extends StatelessWidget {
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

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
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100),
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
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đăng nhập',
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
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: !isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đăng ký',
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
