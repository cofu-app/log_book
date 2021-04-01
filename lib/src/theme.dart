import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData appThemeLight(BuildContext context) => _buildTheme(
      colorScheme: ColorScheme.light(),
    );

ThemeData appThemeDark(BuildContext context) => _buildTheme(
      colorScheme: ColorScheme.dark(),
    );

ThemeData _buildTheme({required ColorScheme colorScheme}) {
  final appBarTheme = AppBarTheme(
    backwardsCompatibility: false,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  final inputDecorationTheme = InputDecorationTheme(
    filled: true,
  );

  return ThemeData.from(
    colorScheme: colorScheme,
  ).copyWith(
    appBarTheme: appBarTheme,
    inputDecorationTheme: inputDecorationTheme,
  );
}
