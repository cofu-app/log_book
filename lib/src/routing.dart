import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'model/model.dart';
import 'pages/pages.dart';

class AppRoutInformationParser
    extends RouteInformationParser<RouteInformation> {
  const AppRoutInformationParser();

  @override
  Future<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) =>
      SynchronousFuture(routeInformation);
}

class AppRouterDelegate extends RouterDelegate<RouteInformation>
    with PopNavigatorRouterDelegateMixin, ChangeNotifier {
  AppRouterDelegate(this._appModel) {
    _appModel.addListener(notifyListeners);
  }

  final AppModel _appModel;

  @override
  void dispose() {
    _appModel.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(void configuration) => SynchronousFuture(null);

  bool _popPage(dynamic result) {
    if (_appModel.newLogBookDialogIsOpen) {
      _appModel.closeNewLogBookDialog();
      return true;
    }

    if (_appModel.logBookIsOpen) {
      _appModel.closeLogBook();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        restorationScopeId: 'rootNavigator',
        onPopPage: (route, dynamic result) {
          if (!route.didPop(result)) {
            return false;
          }

          return _popPage(result);
        },
        pages: [
          _RestorableMaterialPage<void>(
            key: ValueKey('logBookBrowserPage'),
            name: 'logBookBrowserPage',
            restorationId: 'logBookBrowserPage',
            child: LogBookBrowserPage(),
          ),
          if (_appModel.logBookIsOpen)
            _RestorableMaterialPage<void>(
              key: ValueKey('logBookViewerPage'),
              name: 'logBookViewerPage',
              restorationId: 'logBookViewerPage',
              child: LogBookViewerPage(),
            ),
          if (_appModel.newLogBookDialogIsOpen)
            _DialogPage<void>(
              key: ValueKey('newLogBookDialog'),
              name: 'newLogBookDialog',
              restorationId: 'newLogBookDialog',
              builder: (_) => NewLogBookDialog(),
            ),
        ],
      );
}

class _RestorableMaterialPage<T> extends MaterialPage<T> {
  _RestorableMaterialPage({
    required Widget child,
    bool maintainState = true,
    bool fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    this.restorationId,
  }) : super(
          child: child,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          key: key,
          name: name,
          arguments: arguments,
        );

  @override
  final String? restorationId;
}

class _DialogPage<T> extends Page<T> {
  _DialogPage({
    LocalKey? key,
    Object? arguments,
    String? restorationId,
    String? name,
    required this.builder,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute(
        context: context,
        settings: this,
        builder: builder,
      );
}
