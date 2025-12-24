import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00C950);
  static const Color blue = Color(0xFF55ACEE);
  
  // Background Colors
  static const Color background = Color(0xFFF6F7F9);
  static const Color cardBackground = Colors.white;
  static const Color iconBackground = Color(0xFFF3F5F7);
  static const Color buttonBackground = Color(0xFFF5F6F8);
  
  // Text Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF65758B);
  static const Color textMuted = Color(0xFF99A1AF);
  
  // Other Colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x0D000000);
}
	AppColors._();

	/// Primary brand color used across the app.
	///
	/// Kept aligned with existing hard-coded usages in the auth flow.
	static const Color primary = Color(0xFF72BF83);

	/// Default scaffold background.
	static const Color background = Color(0xFFF5F6F8);

	/// Divider / border neutral.
	static const Color divider = Color(0xFFE5E7EB);

	/// Light surface used for placeholders (e.g. avatar fallback).
	static const Color buttonBackground = Color(0xFFF3F4F6);
}
