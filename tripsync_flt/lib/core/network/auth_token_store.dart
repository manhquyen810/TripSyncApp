import 'dart:convert';
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

  static Future<int?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      
      final userId = data['user_id'] ?? data['sub'];
      if (userId == null) return null;
      
      if (userId is int) return userId;
      if (userId is String) return int.tryParse(userId);
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
