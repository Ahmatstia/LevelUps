import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // --- Core Colors ---
  static const Color background = Color(0xFF0F172A); // Deep dark blue/black
  static const Color surface = Color(0xFF1E293B); // Slightly lighter blue/black

  // --- Stat & Energy Colors ---
  static const Color hpRed = Color(0xFFEF4444); // Health/Urgent
  static const Color manaBlue = Color(0xFF3B82F6); // Intelligence/Mana
  static const Color staminaGreen = Color(0xFF10B981); // Discipline/Stamina
  static const Color goldYellow = Color(0xFFF59E0B); // Wealth/Gold

  // --- Accent & Glows ---
  static const Color neonCyan = Color(0xFF22D3EE); // Primary accent
  static const Color neonPink = Color(0xFFEC4899); // Secondary accent

  // --- Text Styles ---
  // Using TextTheme to apply GoogleFonts globally
  static TextTheme get textTheme {
    return GoogleFonts.pressStart2pTextTheme().copyWith(
      // We mix a readable font for descriptions, and 8-bit for headers
      displayLarge: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 24),
      displayMedium: GoogleFonts.pressStart2p(
        color: Colors.white,
        fontSize: 20,
      ),
      displaySmall: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16),
      titleLarge: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 14),
      bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      bodyMedium: GoogleFonts.inter(color: Colors.grey[300], fontSize: 12),
    );
  }

  // --- Theme Data ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPink,
        surface: surface,
        error: hpRed,
      ),
      textTheme: textTheme,

      // Card Theme (Game Panels)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            4,
          ), // Sharp corners for pixel look
          side: const BorderSide(
            color: Colors.white12,
            width: 2, // Thick borders
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldYellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Colors.black87, width: 2),
        ),
        elevation: 6,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.pressStart2p(color: neonCyan, fontSize: 16),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: neonCyan,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
        unselectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // --- Utility Game Styles ---

  // A helper for glowing neon text
  static TextStyle neonTextStyle(Color color, {double fontSize = 16}) {
    return GoogleFonts.pressStart2p(
      color: Colors.white,
      fontSize: fontSize,
      shadows: [
        Shadow(blurRadius: 10.0, color: color, offset: const Offset(0, 0)),
        Shadow(blurRadius: 20.0, color: color, offset: const Offset(0, 0)),
      ],
    );
  }
}
