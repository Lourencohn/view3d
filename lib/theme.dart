import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema visual do View3D — editorial / premium B2B.
/// Coral accent sobre creme quente, tipografia serifa para títulos.
class AppTheme {
  AppTheme._();

  // Brand
  static const accent = Color(0xFFE8513A);
  static const accentDeep = Color(0xFFC93F2A);
  static const accentTint = Color(0xFFFCEBE7);

  // Neutrals (light)
  static const ink = Color(0xFF1A1815);
  static const ink2 = Color(0xFF4A4640);
  static const ink3 = Color(0xFF8A857A);
  static const ink4 = Color(0xFFB8B3A8);
  static const bgApp = Color(0xFFFAF9F6);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgMuted = Color(0xFFF3F1EC);
  static const line = Color(0xFFE8E4DC);
  static const lineStrong = Color(0xFFD8D3C8);

  static const success = Color(0xFF1F8A5B);
  static const warning = Color(0xFFD4A017);

  /// Heading font (Google Fonts: Instrument Serif).
  /// Carregue via `google_fonts` ou inclua em pubspec/assets.
  /// Usamos serif do sistema como fallback enquanto a fonte real não estiver
  /// configurada.
  static const fontDisplay = 'serif';
  static const fontSans = 'system-ui';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      primary: ink,
      onPrimary: bgApp,
      secondary: accent,
      onSecondary: Colors.white,
      surface: bgApp,
      onSurface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bgApp,
      fontFamily: fontSans,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgApp,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: lineStrong),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: lineStrong),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: ink3,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: bgApp,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: bgMuted,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          color: bgApp,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 0.5),
    );
  }
}

/// Estilos tipográficos reutilizáveis.
class AppText {
  AppText._();

  static const displayLarge = TextStyle(
    fontFamily: AppTheme.fontDisplay,
    fontSize: 44,
    height: 1.0,
    letterSpacing: -0.5,
    color: AppTheme.ink,
    fontStyle: FontStyle.italic,
  );

  static const titleXL = TextStyle(
    fontFamily: AppTheme.fontDisplay,
    fontSize: 36,
    height: 1.0,
    letterSpacing: -0.5,
    color: AppTheme.ink,
  );

  static const titleLg = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppTheme.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: AppTheme.ink2,
  );

  static const bodySm = TextStyle(
    fontSize: 13,
    color: AppTheme.ink2,
  );

  static const caption = TextStyle(
    fontSize: 11,
    color: AppTheme.ink3,
    letterSpacing: 1.8,
    fontWeight: FontWeight.w500,
  );

  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AppTheme.ink3,
    letterSpacing: -0.2,
  );
}
