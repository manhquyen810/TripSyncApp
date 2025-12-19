import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'ApiException(message: $message, statusCode: $statusCode, cause: $cause)';
}

class NetworkException extends ApiException {
  const NetworkException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class TimeoutException extends ApiException {
  const TimeoutException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class ServerException extends ApiException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class BadRequestException extends ApiException {
  const BadRequestException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class UnknownApiException extends ApiException {
  const UnknownApiException(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static ApiException fromDio(DioException e, StackTrace st) {
    final status = e.response?.statusCode;
    final message = _extractMessage(e) ?? 'Request failed';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message,
          statusCode: status,
          cause: e,
          stackTrace: st,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return NetworkException(
          message,
          statusCode: status,
          cause: e,
          stackTrace: st,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled',
          statusCode: status,
          cause: e,
          stackTrace: st,
        );

      case DioExceptionType.badResponse:
        return _mapStatus(status, message, e, st);

      case DioExceptionType.unknown:
        return UnknownApiException(
          message,
          statusCode: status,
          cause: e,
          stackTrace: st,
        );
    }
  }

  static ApiException _mapStatus(
    int? status,
    String message,
    DioException e,
    StackTrace st,
  ) {
    if (status == 400 || status == 422) {
      return BadRequestException(
        message,
        statusCode: status,
        cause: e,
        stackTrace: st,
      );
    }
    if (status == 401 || status == 403) {
      return UnauthorizedException(
        message,
        statusCode: status,
        cause: e,
        stackTrace: st,
      );
    }
    if (status == 404) {
      return NotFoundException(
        message,
        statusCode: status,
        cause: e,
        stackTrace: st,
      );
    }
    if (status != null && status >= 500) {
      return ServerException(
        message,
        statusCode: status,
        cause: e,
        stackTrace: st,
      );
    }

    return UnknownApiException(
      message,
      statusCode: status,
      cause: e,
      stackTrace: st,
    );
  }

  static String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;

      // FastAPI validation errors often come as: {"detail": [{"msg": "...", ...}, ...]}
      if (message is List && message.isNotEmpty) {
        final first = message.first;
        if (first is Map<String, dynamic>) {
          final msg = first['msg'];
          if (msg is String && msg.trim().isNotEmpty) return msg;
        }
        // Fallback: stringify the first item.
        final rawFirst = first.toString();
        if (rawFirst.trim().isNotEmpty) return rawFirst;
      }
    }
    final responseText = e.response?.statusMessage;
    if (responseText != null && responseText.trim().isNotEmpty) {
      return responseText;
    }
    final raw = e.message;
    if (raw != null && raw.trim().isNotEmpty) return raw;
    return null;
  }
}
