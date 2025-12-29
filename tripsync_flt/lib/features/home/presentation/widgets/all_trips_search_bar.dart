import 'package:flutter/material.dart';

class AllTripsSearchBar extends StatelessWidget {
  final Function(String)? onSearchChanged;

  const AllTripsSearchBar({
    super.key,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF959DA3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF959DA3),
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chuyến đi..',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF959DA3),
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/icons/search.png',
              width: 24,
              height: 24,
              color: const Color(0xFF959DA3),
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.search,
                size: 24,
                color: Color(0xFF959DA3),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 24,
          ),
        ),
      ),
    );
  }
}
