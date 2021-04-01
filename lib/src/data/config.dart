import 'package:cbl/cbl.dart';
import 'package:cbl_data/cbl_data.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'log_book.dart';
import 'log_book_service.dart';
import 'log_entry.dart';

late final LogBookService logBookService;

Future<void> initDataSources() async {
  CouchbaseLite.initialize(libraries: flutterLibraries());
  CouchbaseLite.logLevel = LogLevel.warning;
  CouchbaseLite.logMessages().logToLogger();

  final appDir = await getApplicationSupportDirectory();

  final db = await Database.open(
    'LogBook',
    config: DatabaseConfiguration(directory: appDir.path),
  );

  await _createIndexes(db);

  final entityMetadataRegistry = EntityMetadataRegistry([
    logBookEntityMetaData,
    logEntryEntityMetaData,
  ]);
  final entityRepositoryContext = EntityRepositoryContext(
    database: db,
    entityMetadataRegistry: entityMetadataRegistry,
  );

  final logBookRepo = LogBookRepository(entityRepositoryContext);
  final logEntryRepo = LogEntryRepository(entityRepositoryContext);

  logBookService = LogBookService(logBookRepo, logEntryRepo);
}

Future<void> _createIndexes(Database db) async {
  await db.createIndex(
    'typeAndId',
    ValueIndex('[[".", "type"], [".", "_id"]]'),
  );

  await db.createIndex(
    'text',
    FullTextIndex('[[".", "text"]]'),
  );
}
