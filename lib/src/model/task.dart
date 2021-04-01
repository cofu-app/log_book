import 'dart:async';

import 'package:flutter/foundation.dart';

enum TaskStatus {
  idle,
  waiting,
  active,
  done,
  error,
  canceled,
}

typedef TaskFutureHandler<T, R> = Future<R> Function(T arguments);

typedef TaskStreamHandler<T, R> = Stream<R> Function(T arguments);

abstract class Task<T, R> extends ChangeNotifier {
  Task._();

  factory Task.future(TaskFutureHandler<T, R> handler) => _FutureTask(handler);

  factory Task.stream(TaskStreamHandler<T, R> handler) => _StreamTask(handler);

  TaskStatus get status => _status;
  TaskStatus _status = TaskStatus.idle;

  R? get result => _result;
  R? _result;

  Object? get error => _error;
  Object? _error;

  StackTrace? get errorStackTrace => _errorStackTrace;
  StackTrace? _errorStackTrace;

  void execute([T? arguments]) {
    if (_status == TaskStatus.waiting || _status == TaskStatus.active) {
      return;
    }

    _status = TaskStatus.waiting;
    _result = null;
    _error = null;

    _execute(arguments);

    notifyListeners();
  }

  void cancel() {
    if (_status != TaskStatus.waiting && _status != TaskStatus.active) {
      return;
    }

    _status = TaskStatus.canceled;
    _result = null;
    _error = null;
    _cancel();
    notifyListeners();
  }

  void _execute([T? arguments]);

  void _cancel();

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  String toString() => 'Task('
      'status: $status, '
      'result: $result, '
      'error: $error, '
      'errorStackTrace: $errorStackTrace'
      ')';
}

class _FutureTask<T, R> extends Task<T, R> {
  _FutureTask(this._handler) : super._();

  final TaskFutureHandler<T, R> _handler;

  void Function()? _cancelPending;

  @override
  void _execute([T? arguments]) {
    var canceled = false;
    _cancelPending = () {
      canceled = true;
    };

    _handler(arguments as T).then((result) {
      if (canceled) {
        return;
      }
      _result = result;
      _status = TaskStatus.done;
      notifyListeners();
    }).catchError((Object error, StackTrace stackTrace) {
      if (canceled) {
        return;
      }
      _status = TaskStatus.error;
      _error = error;
      _errorStackTrace = stackTrace;
      notifyListeners();
    });
  }

  @override
  void _cancel() {
    _cancelPending?.call();
  }
}

class _StreamTask<T, R> extends Task<T, R> {
  _StreamTask(this._handler) : super._();

  final TaskStreamHandler<T, R> _handler;

  StreamSubscription? _subscription;

  @override
  void _execute([T? arguments]) {
    _subscription?.cancel();

    _subscription = _handler(arguments as T).listen(
      (result) {
        _status = TaskStatus.active;
        _result = result;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _subscription!.cancel();
        _status = TaskStatus.error;
        _error = error;
        _errorStackTrace = stackTrace;
        notifyListeners();
      },
      onDone: () {
        _status = TaskStatus.done;
        notifyListeners();
      },
    );
  }

  @override
  void _cancel() {
    _subscription?.cancel();
  }
}
