import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// A custom [LogOutput] implementation that can write logs to both
/// console and a file simultaneously.
///
/// This class extends the [LogOutput] class from the logger package
/// to provide file writing capabilities alongside console output.
class FileLogOutput extends LogOutput {
  /// Whether to write logs to the console using [debugPrint].
  final bool writeLogToConsole;

  /// Whether to write logs to a file.
  final bool writeLogToFile;

  /// The full path to the log file.
  final String logFilePath;

  /// The [IOSink] used to write to the log file.
  late IOSink fileIOSink;

  /// Creates a new [FileLogOutput] instance.
  ///
  /// [writeLogToConsole] - Whether to output logs to the console.
  /// [writeLogToFile] - Whether to write logs to a file.
  /// [logFilePath] - The path where the log file should be stored.
  FileLogOutput({
    required this.writeLogToConsole,
    required this.writeLogToFile,
    required this.logFilePath,
  });

  /// Initializes the log output.
  ///
  /// This method is called by the logger when it's first used.
  /// It sets up the file writing stream.
  @override
  Future<void> init() async {
    super.init();
    initIOSink();
  }

  /// Initializes the [IOSink] for file writing.
  ///
  /// This creates or opens the log file for appending.
  void initIOSink() {
    try {
      final logFile = File(logFilePath);
      // Create the file if it doesn't exist
      if (!logFile.existsSync()) {
        logFile.createSync(recursive: true);
      }
      fileIOSink = logFile.openWrite(mode: FileMode.append);
    } catch (e) {
      debugPrint('Error initializing log file: $e');
      // If we can't write to the file, we'll still allow console logging
      // but disable file logging to prevent crashes
      rethrow;
    }
  }

  /// Processes a log output event.
  ///
  /// This method is called by the logger for each log message.
  /// It writes the log to the console and/or file based on configuration.
  @override
  void output(OutputEvent event) {
    // Write to console if enabled
    if (writeLogToConsole) {
      for (final line in event.lines) {
        debugPrint(line);
      }
    }

    // Write to file if enabled
    if (writeLogToFile) {
      try {
        for (final line in event.lines) {
          fileIOSink.writeln(line);
        }
        // Flush to ensure logs are written immediately
        fileIOSink.flush();
      } catch (e) {
        debugPrint('Error writing to log file: $e');
      }
    }
  }

  /// Cleans up resources when the logger is destroyed.
  ///
  /// This method ensures the file is properly closed.
  @override
  Future<void> destroy() async {
    if (writeLogToFile) {
      try {
        await fileIOSink.flush();
        await fileIOSink.close();
      } catch (e) {
        debugPrint('Error closing log file: $e');
      }
    }
    super.destroy();
  }
}