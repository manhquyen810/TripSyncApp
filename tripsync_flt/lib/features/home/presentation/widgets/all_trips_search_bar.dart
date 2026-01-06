import 'package:flutter/material.dart';

class AllTripsSearchBar extends StatelessWidget {
  final Function(String)? onSearchChanged;

  const AllTripsSearchBar({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFF959DA3);
    final focusColor = const Color(0xFF00C950);

    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chuyến đi...',
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: borderColor,
            fontFamily: 'Inter',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Image.asset(
              'icons/search.png',
              width: 20,
              height: 20,
              color: borderColor,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.search, size: 20, color: borderColor),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor.withAlpha((0.55 * 255).round()),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusColor, width: 1.3),
          ),
        ),
      ),
    );
  }
}
