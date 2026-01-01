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

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
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
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
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
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
      },
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
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{'data': data};
}
