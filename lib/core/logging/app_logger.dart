import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogEntry {
  const AppLogEntry({
    required this.at,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime at;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final tag = level.name.toUpperCase().padRight(7);
    final time = at.toIso8601String();
    final base = '[$time] $tag $message';
    if (error == null) return base;
    return '$base\n  error: $error${stackTrace != null ? '\n  $stackTrace' : ''}';
  }
}

abstract final class AppLogger {
  static const int bufferLimit = 500;

  static final ListQueue<AppLogEntry> _buffer = ListQueue<AppLogEntry>();
  static final StreamController<AppLogEntry> _controller =
      StreamController<AppLogEntry>.broadcast();

  static List<AppLogEntry> get buffer => List.unmodifiable(_buffer);

  static Stream<AppLogEntry> get stream => _controller.stream;

  static void debug(String message) => _log(LogLevel.debug, message);

  static void info(String message) => _log(LogLevel.info, message);

  static void warn(String message, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stack);

  static void error(String message, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.error, message, error: error, stackTrace: stack);

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = AppLogEntry(
      at: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    _buffer.addLast(entry);
    while (_buffer.length > bufferLimit) {
      _buffer.removeFirst();
    }
    if (kDebugMode || level.index >= LogLevel.warning.index) {
      debugPrint(entry.toString());
    }
    if (!_controller.isClosed) {
      _controller.add(entry);
    }
  }

  static void clear() => _buffer.clear();
}
