import 'package:flutter/material.dart';

class AppColors {
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
