import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final EdgeInsetsGeometry padding;

  const HomeHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onProfileTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
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
                child: _buildAvatar(),
              ),
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildAvatar() {
    final url = avatarUrl?.trim();
    if (url == null || url.isEmpty) {
      return Image.asset(
        'assets/icons/person.png',
        width: 20,
        height: 20,
        color: Colors.black,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        url,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/icons/person.png',
          width: 20,
          height: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
