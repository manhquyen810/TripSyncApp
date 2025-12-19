import 'package:dio/dio.dart';

import '../config/env.dart';
import '../utils/logger.dart';
import 'exceptions.dart';

typedef AuthTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({Dio? dio, AuthTokenProvider? authTokenProvider})
    : _dio = dio ?? _defaultDio(authTokenProvider: authTokenProvider),
      _authTokenProvider = authTokenProvider;

  final Dio _dio;
  final AuthTokenProvider? _authTokenProvider;

  Dio get rawDio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: await _withAuth(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(e, st);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _withAuth(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(e, st);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _withAuth(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(e, st);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _withAuth(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(e, st);
    }
  }

  Future<Options?> _withAuth(Options? options) async {
    final tokenProvider = _authTokenProvider;
    if (tokenProvider == null) return options;

    final token = await tokenProvider();
    if (token == null || token.isEmpty) return options;

    final mergedHeaders = <String, dynamic>{
      ...?options?.headers,
      'Authorization': 'Bearer $token',
    };

    return (options ?? Options()).copyWith(headers: mergedHeaders);
  }

  static Dio _defaultDio({AuthTokenProvider? authTokenProvider}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        contentType: Headers.jsonContentType,
        // Render free-tier / cold-start can exceed 20s.
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token at interceptor-level too (covers raw Dio usage).
          if (authTokenProvider != null &&
              (options.headers['Authorization'] == null ||
                  (options.headers['Authorization'] as String?)?.isEmpty ==
                      true)) {
            final token = await authTokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          AppLogger.d(
            '➡️ ${options.method} ${options.baseUrl}${options.path}',
            tag: 'API',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            '✅ ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
            tag: 'API',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.e(
            '❌ ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path} | ${error.response?.statusCode} | data: ${error.response?.data}',
            tag: 'API',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
