import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'log_book.dart';
import 'log_entry.dart';

part 'serializers.g.dart';

@SerializersFor([
  LogBook,
  LogEntry,
  LogBookSummary,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(Iso8601DateTimeSerializer()))
    .build();
