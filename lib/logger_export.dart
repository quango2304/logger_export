library logger_export;

import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:logger_export/file_log_output.dart';
import 'package:path_provider/path_provider.dart';

abstract class ELogInterface {
  d(
    dynamic message, {
    StackTrace? stackTrace,
  });

  e(
    Object? error, {
    dynamic message,
    StackTrace? stackTrace,
  });

  Future<File?> getLogFile();

  Future<void> clearLogFile();
}

class LoggerExport implements ELogInterface {
  late Logger _logger;
  final _completer = Completer();
  late FileLogOutput _fileLogOutput;

  LoggerExport(
      {bool writeLogToFile = true,
      bool writeLogToConsole = true,
      int errorMethodCount = 4}) {
    _init(
        writeLogToFile: writeLogToFile,
        writeLogToConsole: writeLogToConsole,
        errorMethodCount: errorMethodCount);
  }

  Future<void> _init(
      {bool writeLogToFile = true,
      bool writeLogToConsole = true,
      int errorMethodCount = 4}) async {
    final logFilePath = await _getLogFilePath();
    _fileLogOutput = FileLogOutput(
        writeLogToConsole: writeLogToConsole,
        writeLogToFile: writeLogToFile,
        logFilePath: logFilePath);
    _logger = Logger(
      printer: PrettyPrinter(
          noBoxingByDefault: true,
          methodCount: 0,
          printEmojis: false,
          colors: false,
          errorMethodCount: errorMethodCount),
      output: _fileLogOutput,
    );
    _completer.complete();
  }

  @override
  d(
    dynamic message, {
    StackTrace? stackTrace,
  }) async {
    await _completer.future;
    _logger.d("$_time $message", stackTrace: stackTrace);
  }

  @override
  e(
    Object? error, {
    dynamic message,
    StackTrace? stackTrace,
  }) async {
    await _completer.future;
    _logger.e("$_time [ERROR] $message", error: error, stackTrace: stackTrace);
  }

  @override
  Future<File?> getLogFile() async {
    final logFile = File(await _getLogFilePath());
    if (logFile.existsSync()) {
      return logFile;
    } else {
      return null;
    }
  }

  Future<String> _getLogFilePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return "${appDocDir.path}/elog.txt";
  }

  String get _time {
    final time = DateTime.now();
    return "${time.day}-${time.month} ${time.hour}:${time.minute}:${time.second}";
  }

  @override
  Future<void> clearLogFile() async {
    final logFile = File(await _getLogFilePath());
    if (logFile.existsSync()) {
      await logFile.delete();
      await logFile.create();
      _fileLogOutput.initIOSink();
    }
  }
}
