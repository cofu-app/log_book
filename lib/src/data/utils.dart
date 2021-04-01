import 'dart:math';

import 'package:cbl/cbl.dart';
import 'package:cbl_data/cbl_data.dart';

Future<void> explainQueryWithIndex({
  required Database database,
  required TransformQuery query,
  required Iterable<Index> indexes,
}) async {
  final indexName = 'tmp-${Random().nextInt(1 << 32)}';
  final explainStrPre = await query.explain();
  await Future.wait(
    indexes
        .toList()
        .asMap()
        .entries
        .map((e) => database.createIndex('$indexName-${e.key}', e.value)),
  );
  final explainStrPost = await query.explain();
  await Future.wait(
    indexes
        .toList()
        .asMap()
        .entries
        .map((e) => database.deleteIndex('$indexName-${e.key}')),
  );

  print('''
===> Pre Index  <===============================================================
$explainStrPre
===> Post Index <===============================================================
$explainStrPost
================================================================================
''');
}
