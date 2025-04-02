import 'package:flutter/material.dart';

class ThemeConfig {
  static ThemeData get themeData {
    return ThemeData(
      fontFamily: 'Space Grotesk',
      colorScheme: const ColorScheme.light(primary: Color.fromRGBO(220, 9, 26, 1)),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
    );
  }
}
