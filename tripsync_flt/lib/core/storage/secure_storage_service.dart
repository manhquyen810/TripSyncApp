import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _kAccessToken = 'auth.accessToken';
  static const String _kSavedEmail = 'auth.savedEmail';

  static Future<void> saveToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: _kAccessToken, value: trimmed);
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _kAccessToken);
    if (token == null || token.trim().isEmpty) return null;
    return token;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _kAccessToken);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> saveEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: _kSavedEmail, value: trimmed);
  }

  static Future<String?> getSavedEmail() async {
    final email = await _storage.read(key: _kSavedEmail);
    if (email == null || email.trim().isEmpty) return null;
    return email;
  }

  static Future<void> deleteSavedEmail() async {
    await _storage.delete(key: _kSavedEmail);
  }
}
