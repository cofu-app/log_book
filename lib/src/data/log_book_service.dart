import 'package:cbl_data/cbl_data.dart';

import '../data/log_book.dart';
import '../data/log_entry.dart';
import 'exceptions.dart';

class LogBookService {
  LogBookService(this._logBookRepo, this._logEntryRepo);

  final LogBookRepository _logBookRepo;
  final LogEntryRepository _logEntryRepo;

  Future<LogBook> createLogBook(LogBook logBook) async {
    final _logBook = LogBook(
      (b) => b
        ..title = logBook.title
        ..createdAt = DateTime.now().toUtc(),
    );

    return _logBookRepo.save(_logBook);
  }

  Future<void> deleteLogBook(String id) async {
    await _logEntryRepo.deleteByLogBookId(id);
    await _logBookRepo.deleteById(id);
  }

  Future<void> deleteAllLogBooks() async {
    final logBooks = await _logBookRepo.findAll().execute();
    await Future.wait(logBooks.map((it) => it.id!).map(deleteLogBook));
  }

  Future<LogBook> getLogBook(String id) =>
      _logBookRepo.findByIdOrNull(id).execute().requireFound();

  Stream<List<LogBookSummary>> watchAllLogBooks() =>
      _logBookRepo.findAllSummaries().withList().changes();

  Future<LogEntry> createLogEntry(LogEntry logEntry) async {
    final _logEntry = logEntry.rebuild(
      (b) => b..createdAt = DateTime.now().toUtc(),
    );

    return _logEntryRepo.save(_logEntry);
  }

  Future<LogEntry> updateLogEntry(LogEntry logEntry) {
    final _logEntry = logEntry.rebuild(
      (b) => b..updatedAt = DateTime.now().toUtc(),
    );
    return _logEntryRepo.save(_logEntry);
  }

  Future<void> deleteLogEntry(String id) => _logEntryRepo.deleteById(id);

  Stream<List<LogEntry>> watchLogEntries({required String logBookId}) =>
      _logEntryRepo.findByLogBookId(logBookId).withList().changes();

  Future<List<LogEntry>> searchLogEntires({
    required String logBookId,
    required String query,
  }) =>
      _logEntryRepo
          .search(logBookId: logBookId, query: query)
          .withList()
          .execute();
}
