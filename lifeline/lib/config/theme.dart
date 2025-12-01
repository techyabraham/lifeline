import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color primaryColor = Color(0xFF0047AB);
final Color accentColor = Color(0xFFFF3B30);
final Color secondaryColor = Colors.white;
final Color highlightColor = Colors.lime;

final ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
  ),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: GoogleFonts.inter().fontFamily,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: accentColor,
  ),
  fontFamily: GoogleFonts.inter().fontFamily,
);
