# Logger Export Example

This example demonstrates how to use the Logger Export package in a Flutter application.

## Features Demonstrated

This example app shows:

1. How to initialize the Logger Export package
2. How to log debug messages and errors
3. How to export log files for sharing
4. How to clear log files

## Getting Started

1. Clone the repository
2. Run `flutter pub get` in the example directory
3. Run the app on your device or emulator

## Usage

The app has a simple counter interface with additional buttons to demonstrate logging functionality:

- Pressing the "+" button increments the counter and logs debug messages and a sample error
- The "export log file" button retrieves the log file and shares it using the share_plus package
- The "clear log file" button clears the log file

## Code Explanation

### Logger Initialization

```dart
final log = LoggerExport(
  writeLogToFile: true,
  writeLogToConsole: true
);
```

### Logging Messages

```dart
// Log debug messages
log.d("debug when ${{"a": 2}}");
log.d([0, 1, 2, 3]);

// Log errors with stack trace
try {
  throw Exception("some except");
} catch (e, s) {
  log.e(e, stackTrace: s);
}
```

### Exporting Logs

```dart
final logFile = await log.getLogFile();
if(logFile != null) {
  Share.shareXFiles([
    XFile(logFile.path)
  ]);
}
```

### Clearing Logs

```dart
await log.clearLogFile();
```

## Additional Resources

For more information on using Flutter, check out these resources:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Logger Export Package Documentation](https://github.com/quango2304/logger_export)
