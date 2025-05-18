/// A Flutter package for logging to both console and file with export capabilities.
library logger_export;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:logger_export/file_log_output.dart';
import 'package:path_provider/path_provider.dart';

/// Interface defining the core functionality of the logger.
///
/// This interface defines the methods that any logger implementation
/// must provide, including debug and error logging, and file operations.
abstract class LoggerInterface {
  /// Logs a debug message.
  ///
  /// [message] - The message or object to log.
  /// [stackTrace] - Optional stack trace to include with the log.
  Future<void> d(dynamic message, {StackTrace? stackTrace});

  /// Logs an error message.
  ///
  /// [error] - The error object to log.
  /// [message] - Optional additional message to include with the error.
  /// [stackTrace] - Optional stack trace to include with the log.
  Future<void> e(Object? error, {dynamic message, StackTrace? stackTrace});

  /// Retrieves the log file.
  ///
  /// Returns the File object representing the log file if it exists,
  /// or null if the file doesn't exist.
  Future<File?> getLogFile();

  /// Clears the log file.
  ///
  /// This deletes the contents of the log file and creates a new empty file.
  Future<void> clearLogFile();
}

/// A logger implementation that can write logs to both console and file.
///
/// This class provides methods to log debug and error messages, and to
/// manage the log file (retrieving and clearing it).
class LoggerExport implements LoggerInterface {
  /// The underlying logger instance from the logger package.
  late Logger _logger;

  /// Completer used to ensure initialization is complete before logging.
  final _completer = Completer<void>();

  /// The file output handler for writing logs to a file.
  late FileLogOutput _fileLogOutput;

  /// The default log file name.
  static const String _defaultLogFileName = "elog.txt";

  /// Creates a new [LoggerExport] instance.
  ///
  /// [writeLogToFile] - Whether to write logs to a file (default: true).
  /// [writeLogToConsole] - Whether to print logs to console (default: true).
  /// [errorMethodCount] - Number of stack trace method calls to display for errors (default: 4).
  /// [logFileName] - Optional custom log file name (default: "elog.txt").
  LoggerExport({
    bool writeLogToFile = true,
    bool writeLogToConsole = true,
    int errorMethodCount = 4,
    String? logFileName,
  }) {
    _init(
      writeLogToFile: writeLogToFile,
      writeLogToConsole: writeLogToConsole,
      errorMethodCount: errorMethodCount,
      logFileName: logFileName,
    );
  }

  /// Initializes the logger.
  ///
  /// This method sets up the file output and configures the logger.
  Future<void> _init({
    required bool writeLogToFile,
    required bool writeLogToConsole,
    required int errorMethodCount,
    String? logFileName,
  }) async {
    try {
      final logFilePath = await _getLogFilePath(logFileName);

      _fileLogOutput = FileLogOutput(
        writeLogToConsole: writeLogToConsole,
        writeLogToFile: writeLogToFile,
        logFilePath: logFilePath,
      );

      _logger = Logger(
        printer: PrettyPrinter(
          noBoxingByDefault: true,
          methodCount: 0,
          printEmojis: false,
          colors: false,
          errorMethodCount: errorMethodCount,
        ),
        output: _fileLogOutput,
        filter: ProductionFilter(),
      );

      _completer.complete();
    } catch (e) {
      _completer.completeError(e);
      if (kDebugMode) {
        print('Error initializing logger: $e');
      }
    }
  }

  /// Logs a debug message.
  ///
  /// [message] - The message or object to log.
  /// [stackTrace] - Optional stack trace to include with the log.
  @override
  Future<void> d(dynamic message, {StackTrace? stackTrace}) async {
    try {
      await _completer.future;
      _logger.d("$_formattedTime $message", stackTrace: stackTrace);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging debug message: $e');
      }
    }
  }

  /// Logs an error message.
  ///
  /// [error] - The error object to log.
  /// [message] - Optional additional message to include with the error.
  /// [stackTrace] - Optional stack trace to include with the log.
  @override
  Future<void> e(Object? error, {dynamic message, StackTrace? stackTrace}) async {
    try {
      await _completer.future;
      _logger.e(
        "$_formattedTime [ERROR] ${message ?? ''}",
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging error message: $e');
      }
    }
  }

  /// Retrieves the log file.
  ///
  /// Returns the File object representing the log file if it exists,
  /// or null if the file doesn't exist.
  @override
  Future<File?> getLogFile() async {
    try {
      final logFile = File(await _getLogFilePath(null));
      if (logFile.existsSync()) {
        return logFile;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting log file: $e');
      }
    }
    return null;
  }

  /// Gets the full path to the log file.
  ///
  /// [customFileName] - Optional custom file name to use instead of the default.
  Future<String> _getLogFilePath(String? customFileName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = customFileName ?? _defaultLogFileName;
    return "${appDocDir.path}/$fileName";
  }

  /// Formats the current time for log entries.
  String get _formattedTime {
    final DateTime now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-"
           "${now.month.toString().padLeft(2, '0')} "
           "${now.hour.toString().padLeft(2, '0')}:"
           "${now.minute.toString().padLeft(2, '0')}:"
           "${now.second.toString().padLeft(2, '0')}";
  }

  /// Clears the log file.
  ///
  /// This deletes the contents of the log file and creates a new empty file.
  @override
  Future<void> clearLogFile() async {
    try {
      final logFile = File(await _getLogFilePath(null));
      if (logFile.existsSync()) {
        await logFile.delete();
        await logFile.create();
        _fileLogOutput.initIOSink();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing log file: $e');
      }
    }
  }
}
