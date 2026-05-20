import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuroraTheme {
  // Deep space / neon emergency colors
  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF141722);
  static const Color primaryNeon = Color(0xFF00FFCC); // Cyan
  static const Color secondaryNeon = Color(0xFFB500FF); // Purple
  static const Color warning = Color(0xFFFF3366); // Neon Red/Pink
  static const Color textMain = Color(0xFFE0E5FF);
  static const Color textMuted = Color(0xFF8A93B6);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: surface,
        error: warning,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: primaryNeon),
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.7),
        elevation: 8,
        shadowColor: primaryNeon.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryNeon.withValues(alpha: 0.2),
          foregroundColor: primaryNeon,
          shadowColor: secondaryNeon.withValues(alpha: 0.5),
          elevation: 10,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: primaryNeon, width: 1.5),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
