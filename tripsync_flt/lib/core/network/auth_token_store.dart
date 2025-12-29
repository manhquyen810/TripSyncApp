import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  const AuthTokenStore._();

  static const String _kAccessToken = 'auth.accessToken';

  static Future<void> saveAccessToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, trimmed);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccessToken);
    if (token == null || token.trim().isEmpty) return null;
    return token;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
  }
}
