import 'dart:async';
import 'dart:developer';

import 'package:logging/logging.dart';

final initLogger = Logger('init');

void initLogging() {
  Logger.root.onRecord.listen((record) {
    log(
      record.message,
      sequenceNumber: record.sequenceNumber,
      name: record.loggerName,
      level: record.level.value,
      time: record.time,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

extension LoggerExtension on Logger {
  Future<T> infoTimedTask<T>(String taskName, FutureOr<T> Function() f) async {
    info('Starting "$taskName"');

    final stopwatch = Stopwatch()..start();
    String taskDuration() {
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds.toStringAsFixed(1);
    }

    try {
      final result = await f();
      info('Finished "$taskName" in ${taskDuration()} ms');
      return result;
    } catch (e) {
      info('"$taskName" failed after ${taskDuration()} ms');
      rethrow;
    }
  }
}
