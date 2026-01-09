import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract interface class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> token({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> me();

  Future<Map<String, dynamic>> forgotPassword({required String email});

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
  });

  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? filename,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authRegister,
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'name': name,
      },
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authLogin,
      data: <String, dynamic>{'username': username, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> token({
    required String username,
    required String password,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authToken,
      data: <String, dynamic>{'username': username, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> me() async {
    final response = await _client.get<dynamic>(ApiEndpoints.usersMe);
    return _sanitizeUserEnvelope(_asJsonMap(response.data));
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authForgotPassword,
      data: <String, dynamic>{'email': email},
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authVerifyOtp,
      data: <String, dynamic>{'email': email, 'otp': otp},
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.authResetPassword,
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      },
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    final trimmedName = name.trim();
    final body = <String, dynamic>{'name': trimmedName};

    final trimmedAvatarUrl = avatarUrl?.trim();
    if (trimmedAvatarUrl != null && trimmedAvatarUrl.isNotEmpty) {
      body['avatar_url'] = trimmedAvatarUrl;
    }

    final response = await _client.put<dynamic>(
      ApiEndpoints.usersMe,
      data: body,
    );
    return _sanitizeUserEnvelope(_asJsonMap(response.data));
  }

  @override
  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? filename,
  }) async {
    final trimmedPath = filePath?.trim();
    final hasPath = trimmedPath != null && trimmedPath.isNotEmpty;

    final hasBytes = bytes != null && bytes.isNotEmpty;
    final effectiveFilename = (filename?.trim().isNotEmpty ?? false)
        ? filename!.trim()
        : (hasPath ? trimmedPath.split(RegExp(r'[\\/]+')).last : 'avatar');

    if (!hasPath && !hasBytes) {
      throw ArgumentError('Either filePath or bytes must be provided');
    }

    final multipart = hasBytes
        ? MultipartFile.fromBytes(bytes, filename: effectiveFilename)
        : await MultipartFile.fromFile(
            trimmedPath!,
            filename: effectiveFilename,
          );

    final form = FormData.fromMap({'file': multipart});

    final response = await _client.post<dynamic>(
      ApiEndpoints.usersMeAvatarUpload,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final raw = _asJsonMap(response.data);
    return _extractUploadedUrl(raw);
  }
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{'data': data};
}

Map<String, dynamic> _sanitizeUserEnvelope(Map<String, dynamic> raw) {
  final message = raw['message'];
  final data = raw['data'];

  if (data is Map<String, dynamic>) {
    return <String, dynamic>{
      if (message is String) 'message': message,
      'data': _sanitizeUserJson(data),
    };
  }

  final sanitized = _sanitizeUserJson(raw);
  if (sanitized.isNotEmpty) {
    return <String, dynamic>{
      if (message is String) 'message': message,
      'data': sanitized,
    };
  }

  return raw;
}

Map<String, dynamic> _sanitizeUserJson(Map<String, dynamic> user) {
  // Keep only fields the app should ever need from /users/me.
  // Drop sensitive fields like hashed_password/otp_code.
  final out = <String, dynamic>{};

  void copyKey(String key) {
    if (user.containsKey(key)) {
      out[key] = user[key];
    }
  }

  copyKey('id');
  copyKey('email');
  copyKey('name');
  copyKey('avatar_url');
  copyKey('created_at');
  copyKey('is_active');

  return out;
}

String _extractUploadedUrl(Map<String, dynamic> raw) {
  dynamic data = raw['data'];
  if (data is String && data.trim().isNotEmpty) return data.trim();

  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    const candidates = <String>[
      'url',
      'file_url',
      'fileUrl',
      'download_url',
      'downloadUrl',
      'public_url',
      'publicUrl',
      'path',
      'file_path',
      'filePath',
    ];

    for (final key in candidates) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }

    for (final containerKey in const <String>['file', 'document', 'result']) {
      final nested = map[containerKey];
      if (nested is Map) {
        final nestedMap = Map<String, dynamic>.from(nested);
        for (final key in candidates) {
          final v = nestedMap[key];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }
  }

  throw StateError('Upload response did not contain a file URL');
}
