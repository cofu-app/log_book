import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:cbl/cbl.dart';
import 'package:cbl_data/cbl_data.dart';

import 'common.dart';
import 'serializers.dart';

part 'log_entry.g.dart';

abstract class LogEntry
    with Entity, Timestamped
    implements Built<LogEntry, LogEntryBuilder> {
  String get logBookId;

  String get text;

  LogEntry._();
  factory LogEntry([void Function(LogEntryBuilder) updates]) = _$LogEntry;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(LogEntry.serializer, this)
          as Map<String, dynamic>;

  static LogEntry fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(LogEntry.serializer, json)!;

  static Serializer<LogEntry> get serializer => _$logEntrySerializer;
}

final logEntryEntityMetaData = EntityMetadata<LogEntry>(
  typeName: 'LogEntry',
  deserializer: LogEntry.fromJson,
);

class LogEntryRepository extends EntityRepository<LogEntry> {
  LogEntryRepository(EntityRepositoryContext context)
      : _queryTemplate = QueryTemplate(context.database),
        _queryUtils = N1QLEntityQueryUtils(
          context.entityMetadataRegistry,
          context.entityConverter,
        ),
        super(context);

  final QueryTemplate _queryTemplate;

  final N1QLEntityQueryUtils _queryUtils;

  Future<void> deleteByLogBookId(String logBookId) => findByLogBookId(logBookId)
      .execute()
      .asStream()
      .expand((logEntries) => logEntries)
      .asyncMap(delete)
      .drain<void>();

  TransformQuery<Iterable<LogEntry>> findByLogBookId(String id) =>
      _queryTemplate.findManyResults(
        N1QLQuery('''
        SELECT ${_queryUtils.documentDataSelectionSet('logEntry')}
        FROM logEntry
        WHERE 
          ${_queryUtils.typePredicate<LogEntry>('logEntry')} AND 
          logEntry.logBookId = \$ID
        ORDER BY logEntry.createdAt ASC
        '''),
        (result) => _queryUtils.extractEntityFromResult(result, 'logEntry'),
        parameters: <String, String>{'ID': id},
      );

  TransformQuery<Iterable<LogEntry>> search({
    required String logBookId,
    required String query,
  }) =>
      _queryTemplate.findManyResults(
        N1QLQuery('''
        SELECT ${_queryUtils.documentDataSelectionSet('logEntry')}
        FROM logEntry
        WHERE 
          ${_queryUtils.typePredicate<LogEntry>('logEntry')} AND 
          logEntry.logBookId = \$LOG_BOOK_ID AND
          "text" MATCH \$QUERY
        ORDER BY rank("text")
        LIMIT 15
        '''),
        (result) => _queryUtils.extractEntityFromResult(result, 'logEntry'),
        parameters: <String, String>{
          'LOG_BOOK_ID': logBookId,
          'QUERY': query,
        },
      );
}
