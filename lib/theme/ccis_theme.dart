import 'package:flutter/material.dart';

/// Shared visual language for the CCIS CLEARANCE mobile and web experiences.
abstract final class CcisTheme {
  static const navy = Color(0xFF12385F);
  static const blue = Color(0xFF286DCC);
  static const paleBlue = Color(0xFFEAF2FF);
  static const success = Color(0xFF16824A);
  static const warning = Color(0xFFA65D00);
  static const danger = Color(0xFFC33131);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: brightness,
      primary: isDark ? const Color(0xFF8FC2FF) : blue,
      surface: isDark ? const Color(0xFF121B27) : const Color(0xFFFFFFFF),
      error: isDark ? const Color(0xFFFFB4AB) : danger,
    );
    final outline = isDark ? const Color(0xFF334355) : const Color(0xFFD9E4EF);
    final body = isDark ? const Color(0xFFE4EDF8) : const Color(0xFF233D57);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0D1520) : const Color(0xFFF5F8FC),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: body,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: body,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: body,
            displayColor: body,
          ),
      dividerColor: outline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF192535) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(45),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          side: BorderSide(color: outline),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: isDark ? const Color(0xFF243D5C) : paleBlue,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, color: body, fontSize: 11),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? const Color(0xFF101B29) : Colors.white,
        indicatorColor: isDark ? const Color(0xFF243D5C) : paleBlue,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
