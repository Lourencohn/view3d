import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema visual do TROVATA — corporate B2B com toque editorial.
/// Azul primário sobre neutros frios; vermelho como acento de marca.
///
/// Os tokens "ink/bg/line" são **getters** que respondem ao modo de tema
/// global ([AppTheme.isDark]). Brand colors (azul/vermelho/verde) ficam
/// estáveis em qualquer modo para manter a identidade da marca.
///
/// Por consequência, `const TextStyle(color: AppTheme.ink)` não compila —
/// use `TextStyle(color: AppTheme.ink)` sem `const` quando referenciar
/// cores dependentes de tema.
class AppTheme {
  AppTheme._();

  // ─────────────── Estado do tema ───────────────
  static bool _isDark = false;
  static bool get isDark => _isDark;

  /// Atualiza o flag global. Chamado pelo `themeModeProvider` antes de
  /// reconstruir a árvore (via `notifyListeners` / rebuild do MaterialApp).
  static void setDark(bool value) {
    _isDark = value;
  }

  // ─────────────── Brand (não muda) ───────────────
  static const accent = Color(0xFF1976D2);
  static const accentDeep = Color(0xFF1565C0);
  static const accentTint = Color(0xFFE3F2FD);

  static const brandRed = Color(0xFFD32F2F);
  static const brandRedDeep = Color(0xFFB71C1C);
  static const brandRedTint = Color(0xFFFFEBEE);

  static const brandGreen = Color(0xFF2E7D32);
  static const brandGreenTint = Color(0xFFE8F5E9);

  static const success = brandGreen;
  static const warning = Color(0xFFD4A017);

  // ─────────────── Neutros (claro) ───────────────
  static const _inkLight = Color(0xFF0F172A);
  static const _ink2Light = Color(0xFF334155);
  static const _ink3Light = Color(0xFF64748B);
  static const _ink4Light = Color(0xFF94A3B8);
  static const _bgAppLight = Color(0xFFFBFCFE);
  static const _bgCardLight = Color(0xFFFFFFFF);
  static const _bgMutedLight = Color(0xFFF1F5F9);
  static const _lineLight = Color(0xFFE2E8F0);
  static const _lineStrongLight = Color(0xFFCBD5E1);

  // ─────────────── Neutros (escuro) ───────────────
  static const _inkDark = Color(0xFFF1F5F9);
  static const _ink2Dark = Color(0xFFCBD5E1);
  static const _ink3Dark = Color(0xFF94A3B8);
  static const _ink4Dark = Color(0xFF64748B);
  static const _bgAppDark = Color(0xFF0B1220);
  static const _bgCardDark = Color(0xFF131A2A);
  static const _bgMutedDark = Color(0xFF1E293B);
  static const _lineDark = Color(0xFF1F2A3D);
  static const _lineStrongDark = Color(0xFF334155);

  // ─────────────── Getters (resolvem o token atual) ───────────────
  static Color get ink => _isDark ? _inkDark : _inkLight;
  static Color get ink2 => _isDark ? _ink2Dark : _ink2Light;
  static Color get ink3 => _isDark ? _ink3Dark : _ink3Light;
  static Color get ink4 => _isDark ? _ink4Dark : _ink4Light;
  static Color get bgApp => _isDark ? _bgAppDark : _bgAppLight;
  static Color get bgCard => _isDark ? _bgCardDark : _bgCardLight;
  static Color get bgMuted => _isDark ? _bgMutedDark : _bgMutedLight;
  static Color get line => _isDark ? _lineDark : _lineLight;
  static Color get lineStrong => _isDark ? _lineStrongDark : _lineStrongLight;

  // Brilho do texto no botão preto (no claro, tinta clara; no escuro, ink-deep)
  static Color get onInk => _isDark ? _bgAppLight : _bgAppLight;

  /// Heading font (Google Fonts: Instrument Serif).
  static const fontDisplay = 'serif';
  static const fontSans = 'system-ui';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: dark ? _inkDark : _inkLight,
      onPrimary: dark ? _bgAppDark : _bgAppLight,
      secondary: accent,
      onSecondary: Colors.white,
      surface: dark ? _bgAppDark : _bgAppLight,
      onSurface: dark ? _inkDark : _inkLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? _bgAppDark : _bgAppLight,
      canvasColor: dark ? _bgAppDark : _bgAppLight,
      fontFamily: fontSans,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? _bgAppDark : _bgAppLight,
        foregroundColor: dark ? _inkDark : _inkLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: dark ? _inkDark : _inkLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              color: dark ? _lineStrongDark : _lineStrongLight),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: dark ? _lineStrongDark : _lineStrongLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color: dark ? _ink3Dark : _ink3Light,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? _inkDark : _inkLight,
          foregroundColor: dark ? _bgAppDark : _bgAppLight,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
          foregroundColor: dark ? _inkDark : _inkLight,
          backgroundColor: dark ? _bgMutedDark : _bgMutedLight,
          side: BorderSide.none,
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
        backgroundColor: dark ? _bgCardDark : _inkLight,
        contentTextStyle: TextStyle(
          color: dark ? _inkDark : _bgAppLight,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? _lineDark : _lineLight,
        thickness: 0.5,
      ),
      dialogBackgroundColor: dark ? _bgCardDark : _bgCardLight,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? _bgCardDark : _bgCardLight,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Estilos tipográficos reutilizáveis. Como os campos usam getters de
/// cor de [AppTheme] (não são `const`), estes membros também são getters
/// estáticos. Cada acesso devolve um `TextStyle` resolvido para o tema
/// vigente.
class AppText {
  AppText._();

  static TextStyle get displayLarge => TextStyle(
        fontFamily: AppTheme.fontDisplay,
        fontSize: 44,
        height: 1.0,
        letterSpacing: -0.5,
        color: AppTheme.ink,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get titleXL => TextStyle(
        fontFamily: AppTheme.fontDisplay,
        fontSize: 36,
        height: 1.0,
        letterSpacing: -0.5,
        color: AppTheme.ink,
      );

  static TextStyle get titleLg => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppTheme.ink,
      );

  static TextStyle get body => TextStyle(
        fontSize: 15,
        height: 1.5,
        color: AppTheme.ink2,
      );

  static TextStyle get bodySm => TextStyle(
        fontSize: 13,
        color: AppTheme.ink2,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 11,
        color: AppTheme.ink3,
        letterSpacing: 1.8,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get mono => TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: AppTheme.ink3,
        letterSpacing: -0.2,
      );
}
