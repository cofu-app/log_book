import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'actions.dart';

Map<LogicalKeySet, Intent> _resolveShortcuts(
  Map<LogicalKeySet, Intent> defaultShortcuts, {
  Map<LogicalKeySet, Intent>? macOS,
  Map<LogicalKeySet, Intent>? android,
  Map<LogicalKeySet, Intent>? windows,
  Map<LogicalKeySet, Intent>? linux,
  Map<LogicalKeySet, Intent>? iOS,
  Map<LogicalKeySet, Intent>? fuchsia,
}) {
  Map<LogicalKeySet, Intent>? overrides;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      overrides = android;
      break;
    case TargetPlatform.macOS:
      overrides = macOS;
      break;
    case TargetPlatform.windows:
      overrides = windows;
      break;
    case TargetPlatform.fuchsia:
      overrides = fuchsia;
      break;
    case TargetPlatform.iOS:
      overrides = iOS;
      break;
    case TargetPlatform.linux:
      overrides = linux;
      break;
    default:
      throw UnsupportedError(
        'Platform is not supported: $defaultTargetPlatform',
      );
  }

  return {
    ...defaultShortcuts,
    if (overrides != null) ...overrides,
  };
}

Map<LogicalKeySet, Intent> globalShortcuts() => _resolveShortcuts(
      {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyW,
        }): PopPageIntent(),
      },
      macOS: {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyW,
        }): PopPageIntent(),
      },
    );

Map<LogicalKeySet, Intent> logBookBrowserShortcuts() => _resolveShortcuts(
      {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyN,
        }): NewLogBookIntent(),
      },
      macOS: {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyN,
        }): NewLogBookIntent(),
      },
    );

Map<LogicalKeySet, Intent> logBookBrowserListTileShortcuts({
  required String logBookId,
}) =>
    _resolveShortcuts(
      {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyD,
        }): DeleteLogBookIntent(logBookId)
      },
      macOS: {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyD,
        }): DeleteLogBookIntent(logBookId)
      },
    );

Map<LogicalKeySet, Intent> logEntryFormShortcuts() => _resolveShortcuts(
      {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.enter,
        }): SubmitLogEntryForm()
      },
      macOS: {
        LogicalKeySet.fromSet({
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.enter,
        }): SubmitLogEntryForm()
      },
    );
