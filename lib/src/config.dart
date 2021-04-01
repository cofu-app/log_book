import 'package:flutter/material.dart';

import 'data/config.dart';
import 'logging.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  initLogging();
  await initLogger.infoTimedTask('Init data sources', initDataSources);
}
