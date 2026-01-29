import 'package:flutter/foundation.dart';

class AppStartupTimer {
  static final Stopwatch _stopwatch = Stopwatch();

  static void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  static int get elapsedMs => _stopwatch.elapsedMilliseconds;

  @visibleForTesting
  static void resetForTest() {
    _stopwatch
      ..reset()
      ..stop();
  }
}
