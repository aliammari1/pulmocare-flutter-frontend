import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static const int maxLogFiles = 5;
  static const String logFilePrefix = 'app_log_';

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal();

  Future<String> get _logsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDir.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir.path;
  }

  Future<void> log(
    String message,
    LogLevel level, {
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
  }) async {
    final timestamp = DateTime.now();
    final formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
    final logMessage = '$formattedDate [${level.name.toUpperCase()}] $message'
        '${error != null ? '\nError: $error' : ''}'
        '${stackTrace != null ? '\nStack Trace:\n$stackTrace' : ''}'
        '${userId != null ? ' (User: $userId)' : ''}';

    // Write to today's log file
    await _writeToFile(logMessage);

    // Also print to console in debug mode
    assert(() {
      print(logMessage);
      return true;
    }());
  }

  Future<void> _writeToFile(String message) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logsDir = await _logsDirectory;
    final logFile = File('$logsDir/$logFilePrefix$today.log');

    await logFile.writeAsString('$message\n', mode: FileMode.append);
    await _cleanupOldLogs();
  }

  Future<void> _cleanupOldLogs() async {
    try {
      final logsDir = await _logsDirectory;
      final directory = Directory(logsDir);
      final files = await directory
          .list()
          .where((entity) =>
              entity is File &&
              entity.path.contains(logFilePrefix) &&
              entity.path.endsWith('.log'))
          .toList();

      if (files.length > maxLogFiles) {
        // Sort files by last modified timestamp
        files.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

        // Delete oldest files
        for (var i = maxLogFiles; i < files.length; i++) {
          await files[i].delete();
        }
      }
    } catch (e) {
      print('Failed to cleanup logs: $e');
    }
  }

  Future<List<String>> getRecentLogs({int maxLines = 100}) async {
    try {
      final logsDir = await _logsDirectory;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final logFile = File('$logsDir/$logFilePrefix$today.log');

      if (!await logFile.exists()) {
        return [];
      }

      final lines = await logFile.readAsLines();
      return lines.reversed.take(maxLines).toList().reversed.toList();
    } catch (e) {
      print('Failed to read logs: $e');
      return [];
    }
  }

  Future<void> exportLogs() async {
    try {
      final logsDir = await _logsDirectory;
      final exportFile = File(
          '$logsDir/logs_export_${DateTime.now().millisecondsSinceEpoch}.zip');
      // TODO: Implement log file compression and export
    } catch (e) {
      print('Failed to export logs: $e');
    }
  }
}
