import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:cbl/cbl.dart';
import 'package:cbl_data/cbl_data.dart';

import 'common.dart';
import 'log_entry.dart';
import 'serializers.dart';

part 'log_book.g.dart';

abstract class LogBook
    with Entity, Timestamped
    implements Built<LogBook, LogBookBuilder> {
  String get title;

  LogBook._();
  factory LogBook([void Function(LogBookBuilder) updates]) = _$LogBook;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(LogBook.serializer, this)
          as Map<String, dynamic>;

  static LogBook fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(LogBook.serializer, json)!;

  static Serializer<LogBook> get serializer => _$logBookSerializer;
}

abstract class LogBookSummary
    implements Built<LogBookSummary, LogBookSummaryBuilder> {
  String get id;

  String get title;

  int get entryCount;

  DateTime? get lastEntryCreatedAt;

  LogBookSummary._();
  factory LogBookSummary([void Function(LogBookSummaryBuilder) updates]) =
      _$LogBookSummary;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(LogBookSummary.serializer, this)
          as Map<String, dynamic>;

  static LogBookSummary fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(LogBookSummary.serializer, json)!;

  static Serializer<LogBookSummary> get serializer =>
      _$logBookSummarySerializer;
}

final logBookEntityMetaData = EntityMetadata<LogBook>(
  typeName: 'LogBook',
  deserializer: LogBook.fromJson,
);

class LogBookRepository extends EntityRepository<LogBook> {
  LogBookRepository(EntityRepositoryContext context)
      : _queryTemplate = QueryTemplate(context.database),
        _queryUtils = N1QLEntityQueryUtils(
          context.entityMetadataRegistry,
          context.entityConverter,
        ),
        super(context);

  final QueryTemplate _queryTemplate;

  final N1QLEntityQueryUtils _queryUtils;

  @override
  TransformQuery<Iterable<LogBook>> findAll() => _queryTemplate.findManyResults(
        N1QLQuery('''
        SELECT ${_queryUtils.documentDataSelectionSet()}
        FROM $defaultAlias
        WHERE ${_queryUtils.typePredicate<LogBook>()}
        ORDER BY $defaultAlias.title
        '''),
        (result) => _queryUtils.extractEntityFromResult(result),
      );

  TransformQuery<Iterable<LogBookSummary>> findAllSummaries() =>
      _queryTemplate.findManyResults(
        N1QLQuery('''
        SELECT 
          logBook.META.id AS id, 
          logBook.title AS title,
          count(logEntry.META.id) AS entryCount,
          max(logEntry.createdAt) AS lastEntryCreatedAt
        FROM logBook
        LEFT JOIN logEntry ON 
          ${_queryUtils.typePredicate<LogEntry>('logEntry')} AND
          logEntry.logBookId = logBook.META.id
        WHERE ${_queryUtils.typePredicate<LogBook>('logBook')}
        GROUP BY logBook.META.id
        ORDER BY logBook.title
        '''),
        (result) => LogBookSummary.fromJson(result.dict.toObject()),
      );
}
