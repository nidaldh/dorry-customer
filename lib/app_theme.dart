import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color(0xFF0C8B93);
const kSecondaryColor = Color(0xFFD0B271);
const kSurfaceColor = Colors.white;
const kButtonColor = Color(0xFF0D5F84); // Darker variant of the primary

final appTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    surface: kSurfaceColor,
    // Background color
    error: Colors.red,
    onPrimary: Colors.white,
    // Text color on primary
    onSecondary: Colors.black,
    // Text color on secondary
    onSurface: Colors.black,
    // Text color on background
    onError: Colors.white,
    // Text color on error
    brightness: Brightness.light, // Light or dark mode
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.cairoTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32.0, fontWeight: FontWeight.bold, color: kPrimaryColor),
      displayMedium: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.bold, color: kPrimaryColor),
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
      // Standard body text
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
      // Smaller body text
      labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ), // Button text
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF44ACAC).withOpacity(0.1), // Light fill color
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(color: kPrimaryColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: kButtonColor,
      // Button text color
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.cairo(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      textStyle: GoogleFonts.cairo(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  ),
);
