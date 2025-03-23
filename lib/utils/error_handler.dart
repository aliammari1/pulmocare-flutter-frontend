class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'AppException: $message ${code != null ? '($code)' : ''}';
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is FormatException) {
      return 'Invalid data format';
    } else if (error is TypeError) {
      return 'Type error occurred';
    } else {
      return 'An unexpected error occurred';
    }
  }

  static void logError(dynamic error, StackTrace stackTrace) {
    // TODO: Implement error logging service
    print('ERROR: ${error.toString()}');
    print('STACK TRACE: ${stackTrace.toString()}');
  }

  static bool shouldRetry(Exception error) {
    // Add logic to determine if an operation should be retried
    return false;
  }

  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts || !shouldRetry(e as Exception)) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
  }
}
