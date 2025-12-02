import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF0047AB);
const Color accentColor = Color(0xFFFF3B30);
const Color secondaryColor = Color(0xFFF5F5F5);
const Color healthHighlight = Color(0xFFCCFF00);

final ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: secondaryColor,
  appBarTheme: AppBarTheme(backgroundColor: primaryColor, elevation: 0),
  floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accentColor),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(backgroundColor: primaryColor, elevation: 0),
  floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accentColor),
);
