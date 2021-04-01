import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

typedef RelativeDateWidgetBuilder = Widget Function(
  BuildContext context,
  String time,
);

typedef DateFormatter = String Function(
  Locale locale,
  DateTime now,
  DateTime date,
);

class RelativeDateBuilder extends StatefulWidget {
  static const defaultRefreshDuration = Duration(minutes: 1);

  static String defaultDateFormatter(
    Locale locale,
    DateTime now,
    DateTime date,
  ) {
    const absoluteFormatThreshold = Duration(days: 30);
    final absoluteFormat = DateFormat.yMMMd(locale.toLanguageTag());

    final pastAbsoluteFormatDate = now.subtract(absoluteFormatThreshold);
    final futureAbsoluteFormatDate = now.add(absoluteFormatThreshold);

    if (pastAbsoluteFormatDate.isBefore(date) &&
        futureAbsoluteFormatDate.isAfter(date)) {
      return timeago.format(
        date,
        locale: locale.toLanguageTag(),
        clock: now,
      );
    } else {
      return absoluteFormat.format(date);
    }
  }

  const RelativeDateBuilder({
    Key? key,
    required this.date,
    this.refreshDuration = defaultRefreshDuration,
    this.dateFormatter,
    required this.builder,
  }) : super(key: key);

  final DateTime date;

  final Duration refreshDuration;

  final DateFormatter? dateFormatter;

  final RelativeDateWidgetBuilder builder;

  @override
  _RelativeDateBuilderState createState() => _RelativeDateBuilderState();
}

class _RelativeDateBuilderState extends State<RelativeDateBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void didUpdateWidget(covariant RelativeDateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshDuration != oldWidget.refreshDuration) {
      _setupTimer();
    }
  }

  void _setupTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.refreshDuration, (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final dateFormatter =
        widget.dateFormatter ?? RelativeDateBuilder.defaultDateFormatter;
    return widget.builder(context, dateFormatter(locale, now, widget.date));
  }
}
