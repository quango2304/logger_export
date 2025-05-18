# Logger Export

A Flutter package that helps you log messages to both console and file, with easy export functionality for debugging and troubleshooting.

[![Pub Version](https://img.shields.io/pub/v/logger_export.svg)](https://pub.dev/packages/logger_export)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- Log messages to console and/or file simultaneously
- Support for debug and error log levels
- Timestamp added to each log entry
- Export log files for sharing or analysis
- Clear log files when needed
- Customizable logging options

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  logger_export: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Setup

Create a global logger instance:

```dart
final logger = LoggerExport(
  writeLogToFile: true,    // Write logs to a file
  writeLogToConsole: true, // Also print logs to console
  errorMethodCount: 4      // Number of stack trace lines for errors
);
```

### Logging Messages

Log debug messages:

```dart
// Log simple messages
logger.d("User logged in");

// Log objects or maps
logger.d({"userId": 123, "username": "john_doe"});

// Log arrays/lists
logger.d([0, 1, 2, 3]);
```

Log errors with stack traces:

```dart
try {
  throw Exception("Network connection failed");
} catch (e, stackTrace) {
  // Log the error with its stack trace
  logger.e(e, message: "Failed to connect to server", stackTrace: stackTrace);
}
```

### Exporting Logs

Retrieve the log file for sharing or analysis:

```dart
Future<void> shareLogFile() async {
  final logFile = await logger.getLogFile();
  if (logFile != null) {
    // Use a sharing package like share_plus
    await Share.shareXFiles([XFile(logFile.path)]);
  }
}
```

### Clearing Logs

Clear the log file when needed:

```dart
Future<void> clearLogs() async {
  await logger.clearLogFile();
}
```

## API Reference

### LoggerExport Class

```dart
LoggerExport({
  bool writeLogToFile = true,
  bool writeLogToConsole = true,
  int errorMethodCount = 4
})
```

**Parameters:**

- `writeLogToFile`: Whether to write logs to a file (default: true)
- `writeLogToConsole`: Whether to print logs to console (default: true)
- `errorMethodCount`: Number of stack trace method calls to display for errors (default: 4)

### Methods

- `d(dynamic message, {StackTrace? stackTrace})` - Log a debug message
- `e(Object? error, {dynamic message, StackTrace? stackTrace})` - Log an error
- `Future<File?> getLogFile()` - Get the log file
- `Future<void> clearLogFile()` - Clear the log file

## Example App

Check out the [example](https://github.com/quango2304/logger_export/tree/main/example) directory for a complete sample application.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
