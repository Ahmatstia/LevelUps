import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Colors ---
  static const Color primary = Color(0xFF3F51B5); // Indigo Light
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFFC5CAE9);
  
  static const Color accent = Color(0xFF448AFF); // Blue Accent
  static const Color background = Color(0xFFF8F9FA); // Very light grey/white
  static const Color surface = Colors.white; // Pure white for cards
  
  // --- Stat Colors (Softened for clean UI) ---
  static const Color hpRed = Color(0xFFE57373); // Soft Red
  static const Color manaBlue = Color(0xFF64B5F6); // Soft Blue
  static const Color staminaGreen = Color(0xFF81C784); // Soft Green
  static const Color goldYellow = Color(0xFFFFB74D); // Soft Orange/Yellow

  // --- Text Styles ---
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.inter(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.inter(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
      bodyMedium: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
      bodySmall: GoogleFonts.inter(color: Colors.black38, fontSize: 10),
    );
  }

  // --- Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: hpRed,
      ),
      textTheme: textTheme,

      // Card Theme (Clean UI)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(
          color: primaryDark, 
          fontSize: 18, 
          fontWeight: FontWeight.w600,
        ),
        scrolledUnderElevation: 2,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
