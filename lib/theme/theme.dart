import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 255, 255, 255),
    onSurface: const Color.fromARGB(255, 1, 1, 1),
    primary: const Color.fromARGB(255, 0, 0, 0),
    onPrimary: const Color.fromARGB(255, 137, 137, 137),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 0, 0, 0),
    onSurface: Colors.white,
    primary: const Color.fromARGB(255, 255, 255, 255),
    onPrimary: const Color.fromARGB(255, 137, 137, 137),
  ),
);
