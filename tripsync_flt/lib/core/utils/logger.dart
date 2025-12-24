import 'dart:developer' as developer;

class AppLogger {
  const AppLogger._();

  static void d(
    String message, {
    String tag = 'TripSync',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(message, name: tag, error: error, stackTrace: stackTrace);
  }

  static void e(
    String message, {
    String tag = 'TripSync',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
