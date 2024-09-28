import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    onSurface: Colors.grey.shade800,
    primary: Colors.grey.shade700,
    onPrimary: Colors.white,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    onSurface: Colors.white,
    primary: Colors.grey.shade700,
    onPrimary: Colors.black,
  ),
);
