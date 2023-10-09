import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FileLogOutput extends LogOutput {
  final bool writeLogToConsole;
  final bool writeLogToFile;
  final String logFilePath;
  late IOSink fileIOSink;

  @override
  Future<void> init() async {
    super.init();
    initIOSink();
  }

  void initIOSink() {
    final logFile = File(logFilePath);
    fileIOSink = logFile.openWrite(mode: FileMode.append);
  }

  FileLogOutput({
    required this.writeLogToConsole,
    required this.writeLogToFile,
    required this.logFilePath,
  });

  @override
  void output(OutputEvent event) {
    if (writeLogToConsole) {
      event.lines.forEach(debugPrint);
    }
    if (writeLogToFile) {
      for (var msg in event.lines) {
        fileIOSink.writeln(msg);
      }
    }
  }

  @override
  Future<void> destroy() async {
    fileIOSink.close();
    super.destroy();
  }
}