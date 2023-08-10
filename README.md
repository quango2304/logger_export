# logger_export

A package that help to log and export log file

## example
create global variable
```
final logger =
    LoggerExport(color: false, writeLogToFile: true, writeLogToConsole: true);
```
log any thing
```
    logger.d("debug when ${{"a": 2}}");
    logger.d([0, 1, 2, 3]);
    try {
      throw Exception("some except");
    } catch (e, s) {
    //write error log
      logger.e(e, stackTrace: s);
    }
```
get log file
```
    final logFile = await logger.getLogFile();
```