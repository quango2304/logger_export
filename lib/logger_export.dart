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

  Future<File> getLogFile();
}

class LoggerExport {
  late Logger _logger;
  final _completer = Completer();

  LoggerExport(
      {bool writeLogToFile = true,
      bool writeLogToConsole = true,
      bool color = true,
      int errorMethodCount = 4}) {
    _init(
        writeLogToFile: writeLogToFile,
        writeLogToConsole: writeLogToConsole,
        color: color,
        errorMethodCount: errorMethodCount);
  }

  Future<void> _init(
      {bool writeLogToFile = true,
      bool writeLogToConsole = true,
      bool color = true,
      int errorMethodCount = 4}) async {
    final logFilePath = await _getLogFilePath();
    _logger = Logger(
        printer: PrettyPrinter(
            noBoxingByDefault: true,
            methodCount: 0,
            printEmojis: false,
            colors: color,
            errorMethodCount: errorMethodCount),
        output: FileLogOutput(
            writeLogToConsole: writeLogToConsole,
            writeLogToFile: writeLogToFile,
            logFilePath: logFilePath));
    _completer.complete();
  }

  d(
    dynamic message, {
    StackTrace? stackTrace,
  }) async {
    await _completer.future;
    _logger.d("$_time $message", stackTrace: stackTrace);
  }

  e(
    Object? error, {
    dynamic message,
    StackTrace? stackTrace,
  }) async {
    await _completer.future;
    _logger.e("$_time $message", error: error, stackTrace: stackTrace);
  }

  Future<File> getLogFile() async {
    return File(await _getLogFilePath());
  }

  Future<String> _getLogFilePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return "${appDocDir.path}/elog.txt";
  }

  String get _time {
    final time = DateTime.now();
    return "${time.day}-${time.month} ${time.hour}:${time.minute}:${time.second}";
  }
}
