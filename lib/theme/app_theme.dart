import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Coaches Notepad brand kit — navy, gold and white, strictly (no light
/// blue as a secondary colour). Navy is the app's base; gold is the single
/// accent used for every call-to-action, selected state, highlight and
/// score. Status badge colors stay semantic and intentionally sit outside
/// this brand palette (see the comment above them).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A1628); // brand navy
  static const Color surface = Color(0xFF13243D); // card surface navy
  static const Color surfaceRaised = Color(0xFF1B3252); // slightly lighter, e.g. next-session card
  static const Color border = Color(0xFF26395A);

  static const Color textPrimary = Color(0xFFFFFFFF); // brand white
  static const Color textSecondary = Color(0xFFB7BBC4); // neutral grey — no blue cast
  static const Color textMuted = Color(0xFF7D828C); // neutral grey — no blue cast

  static const Color accentGold = Color(0xFFF5A623); // brand gold — the one accent colour
  static const Color onAccent = Color(0xFF0A1628); // brand navy text/icons on a gold surface

  // Semantic status colors (Reflect screen, Progress mood chart) — kept
  // outside the brand palette on purpose, so a rating always reads the same
  // regardless of brand colour changes.
  static const Color statusExcellent = Color(0xFF3FAE6A);
  static const Color statusGood = Color(0xFF3E7BFA);
  static const Color statusNeutral = Color(0xFF8A97A8);
  static const Color statusTough = Color(0xFFE08A3C);
  static const Color statusDifficult = Color(0xFFE0553C);

  // The pitch diagram in the Session Builder keeps a literal grass green —
  // it represents a football pitch, not the app chrome. Two shades give the
  // drawn pitch mowed-stripe bands.
  static const Color pitchGreen = Color(0xFF1F6B3A);
  static const Color pitchGreenDark = Color(0xFF1B5E30);
  static const Color pitchLine = Color(0x33FFFFFF);
}

/// The Coaches Notepad brand fonts, all from Google Fonts: Bebas Neue for
/// headings, Barlow Condensed Bold for subheadings/section labels, and
/// Montserrat for body copy (set as the app-wide default below, so most
/// `Text` widgets pick it up automatically without naming a fontFamily).
class AppFonts {
  AppFonts._();

  static final String heading = GoogleFonts.bebasNeue().fontFamily!;
  static final String subheading = GoogleFonts.barlowCondensed(fontWeight: FontWeight.bold).fontFamily!;
  static final String body = GoogleFonts.montserrat().fontFamily!;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accentGold,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.accentGold,
        secondary: AppColors.accentGold,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.onAccent,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.body,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.heading,
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.onAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accentGold,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.onAccent),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
