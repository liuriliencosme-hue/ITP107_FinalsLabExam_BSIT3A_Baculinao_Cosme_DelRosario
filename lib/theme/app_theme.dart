import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial palette: near-black ink on warm white paper, with one pink
/// accent reserved for favorites and the main action.
class AppColors {
  static const Color ink = Color(0xFF18181B);
  static const Color inkSoft = Color(0xFF3F3F46);
  static const Color text = Color(0xFF09090B);
  static const Color textMuted = Color(0xFF52525B);
  static const Color textHint = Color(0xFF71717A);
  static const Color paper = Color(0xFFFAFAFA);
  static const Color card = Colors.white;
  static const Color subtle = Color(0xFFF4F4F5);
  static const Color border = Color(0xFFE4E4E7);
  static const Color outline = Color(0xFFA1A1AA);
  static const Color accent = Color(0xFFDB2777);
  static const Color accentSoft = Color(0xFFFDF2F8);
  static const Color onAccentSoft = Color(0xFF831843);
  static const Color danger = Color(0xFFDC2626);

  // Icon colors for messages shown on the dark snack bar.
  static const Color successOnInk = Color(0xFF86EFAC);
  static const Color errorOnInk = Color(0xFFFCA5A5);
  static const Color actionOnInk = Color(0xFFF9A8D4);
}

/// The single [ThemeData] shared by every screen.
class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.inkSoft,
      onSecondary: Colors.white,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentSoft,
      onTertiaryContainer: AppColors.onAccentSoft,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerHighest: AppColors.subtle,
      outline: AppColors.outline,
      outlineVariant: AppColors.border,
    );
    final textTheme = _buildTextTheme(colorScheme);
    final rounded12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 24),
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        iconColor: AppColors.textMuted,
        minVerticalPadding: 14,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: rounded12,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: const BorderSide(color: AppColors.outline),
          shape: rounded12,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(48, 44),
          shape: rounded12,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        extendedTextStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        floatingLabelStyle: const TextStyle(color: AppColors.ink),
        hintStyle: const TextStyle(color: AppColors.textHint),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.ink, 1.5),
        errorBorder: inputBorder(AppColors.danger),
        focusedErrorBorder: inputBorder(AppColors.danger, 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: AppColors.actionOnInk,
        shape: rounded12,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.ink),
    );
  }

  /// Public Sans for reading and interface text; Libre Bodoni for headings
  /// and post titles to give the app an editorial, magazine-like voice.
  static TextTheme _buildTextTheme(ColorScheme colors) {
    final base = GoogleFonts.publicSansTextTheme();
    TextStyle serif(TextStyle? style, double size) {
      return GoogleFonts.libreBodoni(
        textStyle: style,
        fontSize: size,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );
    }

    return base
        .copyWith(
          headlineMedium: serif(base.headlineMedium, 30),
          headlineSmall: serif(base.headlineSmall, 24),
          titleLarge: serif(base.titleLarge, 22),
          titleMedium: serif(base.titleMedium, 18),
          bodyLarge: base.bodyLarge?.copyWith(fontSize: 17, height: 1.7),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface);
  }
}
