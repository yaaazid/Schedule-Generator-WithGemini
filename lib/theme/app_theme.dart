import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ─────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF1D9E75);
  static const Color primaryGreenLight = Color(0xFFE1F5EE);
  static const Color primaryGreenDark = Color(0xFF0F6E56);

  static const Color priorityHigh = Color(0xFFE24B4A);
  static const Color priorityHighLight = Color(0xFFFCEBEB);
  static const Color priorityMedium = Color(0xFFEF9F27);
  static const Color priorityMediumLight = Color(0xFFFAEEDA);
  static const Color priorityLow = Color(0xFF1D9E75);
  static const Color priorityLowLight = Color(0xFFE1F5EE);

  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8F8F6);
  static const Color backgroundTertiary = Color(0xFFF1EFE8);

  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF6B6B67);
  static const Color textTertiary = Color(0xFF9E9E9A);

  static const Color borderLight = Color(0xFFE8E8E4);
  static const Color borderMedium = Color(0xFFD0D0CC);

  // ─── Light Theme ─────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: primaryGreenDark,
        surface: backgroundPrimary,
        // ignore: deprecated_member_use
        background: backgroundSecondary,
        error: priorityHigh,
      ),
      scaffoldBackgroundColor: backgroundSecondary,
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.08,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: backgroundPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundPrimary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderMedium, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderMedium, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: priorityHigh, width: 1),
        ),
        // Penting: warna teks yang diketik user harus eksplisit
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: textSecondary,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: textTertiary,
        ),
        // Warna teks input saat tidak fokus dan fokus
        floatingLabelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: primaryGreen,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderMedium, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundSecondary,
        side: const BorderSide(color: borderLight, width: 0.5),
        labelStyle: GoogleFonts.dmSans(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 0.5,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundPrimary,
        indicatorColor: primaryGreenLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreenDark, size: 22);
          }
          return const IconThemeData(color: textTertiary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryGreenDark,
            );
          }
          return GoogleFonts.dmSans(
            fontSize: 12,
            color: textTertiary,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: const Color(0xFF5DCAA5),
        surface: const Color(0xFF1C1C1A),
        // ignore: deprecated_member_use
        background: const Color(0xFF141412),
        error: priorityHigh,
      ),
      scaffoldBackgroundColor: const Color(0xFF141412),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C1C1A),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1C1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF2C2C2A), width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

// ─── Color Helpers ────────────────────────────────────────

Color priorityColor(String priority) {
  switch (priority) {
    case 'high':
      return AppTheme.priorityHigh;
    case 'medium':
      return AppTheme.priorityMedium;
    default:
      return AppTheme.primaryGreen;
  }
}

Color priorityLightColor(String priority) {
  switch (priority) {
    case 'high':
      return AppTheme.priorityHighLight;
    case 'medium':
      return AppTheme.priorityMediumLight;
    default:
      return AppTheme.priorityLowLight;
  }
}

String priorityLabel(String priority) {
  switch (priority) {
    case 'high':
      return 'Tinggi';
    case 'medium':
      return 'Sedang';
    default:
      return 'Rendah';
  }
}