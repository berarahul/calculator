import 'package:flutter/material.dart';

import 'Colors.dart';

var lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: lightBgColor,
      onBackground: lightFontColor,
      primaryContainer: lightContainer,
      primary: lightPrmary,
    ));
var darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: darkBgColor,
      onBackground: darkFontColor,
      primaryContainer: darkContainer,
      primary: darkPrimary,
    ));
