import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_data.dart';

class ProfileStore {
  static const _kName = 'profile.name';
  static const _kEmail = 'profile.email';
  static const _kPhone = 'profile.phone';
  static const _kAddress = 'profile.address';
  static const _kAvatarPath = 'profile.avatarPath';

  static Future<ProfileData> load() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(_kName) ?? ProfileData.demo.name;
    final email = prefs.getString(_kEmail) ?? ProfileData.demo.email;
    final phone = prefs.getString(_kPhone) ?? ProfileData.demo.phone;
    final address = prefs.getString(_kAddress) ?? ProfileData.demo.address;
    final avatarPath = prefs.getString(_kAvatarPath);

    Uint8List? avatarBytes;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final file = File(avatarPath);
      if (await file.exists()) {
        try {
          avatarBytes = await file.readAsBytes();
        } catch (_) {
          avatarBytes = null;
        }
      }
    }

    return ProfileData(
      name: name,
      email: email,
      phone: phone,
      address: address,
      avatarBytes: avatarBytes,
      avatarPath: avatarPath,
    );
  }

  static Future<ProfileData> save(ProfileData data) async {
    final prefs = await SharedPreferences.getInstance();

    String? savedAvatarPath = data.avatarPath;
    if (data.avatarBytes != null && data.avatarBytes!.isNotEmpty) {
      savedAvatarPath = await _writeAvatarBytes(data.avatarBytes!);
    } else if (data.avatarPath != null && data.avatarPath!.isNotEmpty) {
      savedAvatarPath = await _copyAvatarFromPath(data.avatarPath!);
    }

    await prefs.setString(_kName, data.name);
    await prefs.setString(_kEmail, data.email);
    await prefs.setString(_kPhone, data.phone);
    await prefs.setString(_kAddress, data.address);
    if (savedAvatarPath != null && savedAvatarPath.isNotEmpty) {
      await prefs.setString(_kAvatarPath, savedAvatarPath);
    }

    return data.copyWith(avatarPath: savedAvatarPath);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    final avatarPath = prefs.getString(_kAvatarPath);
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final file = File(avatarPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kPhone);
    await prefs.remove(_kAddress);
    await prefs.remove(_kAvatarPath);
  }

  static Future<String> _writeAvatarBytes(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}${Platform.pathSeparator}profile');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file = File('${folder.path}${Platform.pathSeparator}avatar.bin');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<String> _copyAvatarFromPath(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      return sourcePath;
    }
    final bytes = await source.readAsBytes();
    return _writeAvatarBytes(bytes);
  }
}
