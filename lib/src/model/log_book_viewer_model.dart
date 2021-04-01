import 'package:flutter/foundation.dart';

import '../data/data.dart';
import 'task.dart';

class LogBookViewerModel extends ChangeNotifier {
  LogBookViewerModel(this.logBookId, this._logBookService) {
    loadLogBookTask.addListener(notifyListeners);
    watchLogEntiresTask.addListener(notifyListeners);
    searchLogEntiresTask.addListener(() {
      if (_lastSearchResults != searchLogEntiresTask.result) {
        _lastSearchResults = searchLogEntiresTask.result;
        notifyListeners();
      }
    });
  }

  final String logBookId;

  final LogBookService _logBookService;

  late final loadLogBookTask = Task<void, LogBook>.future(
    (_) => _logBookService.getLogBook(logBookId),
  );

  late final watchLogEntiresTask = Task<void, List<LogEntry>>.stream(
    (_) => _logBookService.watchLogEntries(logBookId: logBookId),
  );

  late final searchLogEntiresTask = Task<String, List<LogEntry>>.future(
    (query) => _logBookService.searchLogEntires(
      logBookId: logBookId,
      query: '$query*',
    ),
  );

  late final createLogEntryTask = Task<String, LogEntry>.future(
    (text) => _logBookService
        .createLogEntry(LogEntry(
      (b) => b
        ..logBookId = logBookId
        ..text = text,
    ))
        .then((entry) {
      onEntrySaved?.call();
      return entry;
    }),
  );

  late final updateLogEntryTask = Task<String, LogEntry>.future(
    (text) => _logBookService
        .updateLogEntry(_currentlyEditedEntry!.rebuild(
      (b) => b..text = text,
    ))
        .then((entry) {
      onEntrySaved?.call();
      cancelEditEntry();
      return entry;
    }),
  );

  late final deleteLogEntryTask = Task<String, void>.future(
    (id) => _logBookService.deleteLogEntry(id),
  );

  VoidCallback? onEntrySaved;

  LogEntry? get currentlyEditedEntry => _currentlyEditedEntry;
  LogEntry? _currentlyEditedEntry;

  void editEntry(String id) {
    if (_currentlyEditedEntry?.id == id) {
      return;
    }

    _currentlyEditedEntry =
        watchLogEntiresTask.result!.firstWhere((entry) => entry.id == id);

    notifyListeners();
  }

  void saveEntry({required String text}) {
    if (_currentlyEditedEntry != null) {
      updateLogEntryTask.execute(text);
    } else {
      createLogEntryTask.execute(text);
    }
  }

  void cancelEditEntry() {
    _currentlyEditedEntry = null;
    notifyListeners();
  }

  void deleteEntry(String id) {
    if (_currentlyEditedEntry?.id == id) {
      cancelEditEntry();
    }
    deleteLogEntryTask.execute(id);
  }

  List<LogEntry>? _lastSearchResults;

  List<LogEntry>? get lastEntriesSearchResults => _lastSearchResults;

  String? _logEntriesQuery;

  void setSearchEntriesQuery(String query) {
    if (_logEntriesQuery != query) {
      _logEntriesQuery = query;
      searchLogEntiresTask.execute(query);
    }
  }

  void load() {
    loadLogBookTask.execute();
    watchLogEntiresTask.execute();
  }

  @override
  void dispose() {
    loadLogBookTask.dispose();
    watchLogEntiresTask.dispose();
    searchLogEntiresTask.dispose();
    createLogEntryTask.dispose();
    updateLogEntryTask.dispose();
    deleteLogEntryTask.dispose();
    super.dispose();
  }
}
