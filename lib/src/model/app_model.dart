import 'package:flutter/foundation.dart';

import '../data/data.dart';
import '../library/library.dart';
import 'log_book_viewer_model.dart';

class AppModel extends ChangeNotifier implements RestorableObject {
  AppModel(this._logBookService);

  final LogBookService _logBookService;

  void createLogBook({required String title}) {
    final logBook = LogBook(
      (b) => b..title = title,
    );
    _logBookService.createLogBook(logBook).then((logBook) {
      closeNewLogBookDialog();
      openLogBook(logBook.id!);
    });
  }

  void deleteLogBook(String id) {
    _logBookService.deleteLogBook(id).then((_) {
      if (logBookViewer?.logBookId == id) {
        closeLogBook();
      }
    });
  }

  void deleteAllLogBooks() {
    _logBookService.deleteAllLogBooks().then((_) {
      if (logBookIsOpen) {
        closeLogBook();
      }
    });
  }

  Stream<List<LogBookSummary>> watchAllLogBooks() =>
      _logBookService.watchAllLogBooks();

  LogBookViewerModel? _logBookViewer;

  LogBookViewerModel? get logBookViewer => _logBookViewer;

  bool get logBookIsOpen => logBookViewer != null;

  void openLogBook(String logBookId) {
    if (_logBookViewer?.logBookId == logBookId) {
      return;
    }

    _logBookViewer = LogBookViewerModel(logBookId, _logBookService)..load();
    _logBookViewer!.addListener(notifyListeners);
    notifyListeners();
  }

  void closeLogBook() {
    if (_logBookViewer == null) {
      return;
    }

    _logBookViewer!.dispose();
    _logBookViewer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _logBookViewer?.dispose();
    super.dispose();
  }

  @override
  Object? restorationData() => <String, dynamic>{
        'currentLogBookId': _logBookViewer?.logBookId,
        'newLogBookDialogIsOpen': _newLogBookDialogIsOpen,
      };

  @override
  void restore(Object? data) {
    final _data = data!.asJsonObject();

    final currentLogBookId = _data.getString('currentLogBookId');
    if (currentLogBookId != null) {
      openLogBook(currentLogBookId);
    } else {
      closeLogBook();
    }

    _newLogBookDialogIsOpen = _data.getBool('newLogBookDialogIsOpen')!;

    notifyListeners();
  }

  bool get newLogBookDialogIsOpen => _newLogBookDialogIsOpen;
  bool _newLogBookDialogIsOpen = false;

  void openNewLogBookDialog() {
    if (!_newLogBookDialogIsOpen) {
      _newLogBookDialogIsOpen = true;
      notifyListeners();
    }
  }

  void closeNewLogBookDialog() {
    if (_newLogBookDialogIsOpen) {
      _newLogBookDialogIsOpen = false;
      notifyListeners();
    }
  }
}
