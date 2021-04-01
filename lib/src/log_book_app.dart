import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/data.dart';
import 'library/library.dart';
import 'model/model.dart';
import 'routing.dart';
import 'theme.dart';

class LogBookApp extends StatefulWidget {
  @override
  _LogBookAppState createState() => _LogBookAppState();
}

class _LogBookAppState extends State<LogBookApp> {
  final _appModel = AppModel(logBookService);
  late final _routerDelegate = AppRouterDelegate(_appModel);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ListenableProvider.value(value: _appModel),
        ],
        child: MaterialApp.router(
          restorationScopeId: 'root',
          debugShowCheckedModeBanner: false,
          routerDelegate: _routerDelegate,
          routeInformationParser: const AppRoutInformationParser(),
          actions: {
            ...WidgetsApp.defaultActions,
            ...globalActions(_appModel),
          },
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            ...globalShortcuts(),
          },
          theme: appThemeLight(context),
          darkTheme: appThemeDark(context),
          builder: (_, child) => RestorableObjectRegistration(
            restorationId: 'appModel',
            object: _appModel,
            child: child!,
          ),
        ),
      );
}
