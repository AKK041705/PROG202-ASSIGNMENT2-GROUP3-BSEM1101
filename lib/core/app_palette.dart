import 'package:flutter/material.dart';

/// The accent (brand) colours a user can choose in Settings.
enum AccentOption { green, blue, purple, orange }

extension AccentOptionInfo on AccentOption {
  String get label {
    switch (this) {
      case AccentOption.green:
        return 'Green';
      case AccentOption.blue:
        return 'Blue';
      case AccentOption.purple:
        return 'Purple';
      case AccentOption.orange:
        return 'Orange';
    }
  }

  /// The colour shown on the picker circle.
  Color get swatch {
    switch (this) {
      case AccentOption.green:
        return const Color(0xFF16803C);
      case AccentOption.blue:
        return const Color(0xFF0B6BB8);
      case AccentOption.purple:
        return const Color(0xFF6A3FB5);
      case AccentOption.orange:
        return const Color(0xFFC2570A);
    }
  }
}

/// Every colour the app uses for one theme (light or dark, plus an accent).
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.accent,
    required this.accentDark,
    required this.accentTint,
    required this.success,
    required this.successTint,
    required this.info,
    required this.infoTint,
    required this.amber,
    required this.amberTint,
    required this.red,
    required this.redTint,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Brightness brightness;
  final Color accent;
  final Color accentDark;
  final Color accentTint;
  final Color success;
  final Color successTint;
  final Color info;
  final Color infoTint;
  final Color amber;
  final Color amberTint;
  final Color red;
  final Color redTint;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  bool get isDark => brightness == Brightness.dark;

  /// Builds the palette for an accent colour in light or dark mode.
  static AppPalette build({
    required AccentOption accent,
    required bool dark,
  }) {
    Color main;
    Color deep;
    Color tint;

    if (dark) {
      switch (accent) {
        case AccentOption.green:
          main = const Color(0xFF2F9E5A);
          deep = const Color(0xFF1F7A41);
          tint = const Color(0xFF1B3A28);
        case AccentOption.blue:
          main = const Color(0xFF2F86D0);
          deep = const Color(0xFF1F65A3);
          tint = const Color(0xFF17314A);
        case AccentOption.purple:
          main = const Color(0xFF8A62D6);
          deep = const Color(0xFF6A45B0);
          tint = const Color(0xFF2B2145);
        case AccentOption.orange:
          main = const Color(0xFFD9722A);
          deep = const Color(0xFFB05A1C);
          tint = const Color(0xFF402A18);
      }
    } else {
      switch (accent) {
        case AccentOption.green:
          main = const Color(0xFF16803C);
          deep = const Color(0xFF0E5A2A);
          tint = const Color(0xFFE2F2E7);
        case AccentOption.blue:
          main = const Color(0xFF0B6BB8);
          deep = const Color(0xFF084E87);
          tint = const Color(0xFFE2F0FA);
        case AccentOption.purple:
          main = const Color(0xFF6A3FB5);
          deep = const Color(0xFF4B2A86);
          tint = const Color(0xFFEDE6FA);
        case AccentOption.orange:
          main = const Color(0xFFC2570A);
          deep = const Color(0xFF8F3F05);
          tint = const Color(0xFFFFEBDD);
      }
    }

    if (dark) {
      return AppPalette(
        brightness: Brightness.dark,
        accent: main,
        accentDark: deep,
        accentTint: tint,
        success: const Color(0xFF62D68C),
        successTint: const Color(0xFF1B3A28),
        info: const Color(0xFF72BDFA),
        infoTint: const Color(0xFF17314A),
        amber: const Color(0xFFFFC766),
        amberTint: const Color(0xFF3D2F10),
        red: const Color(0xFFFF8585),
        redTint: const Color(0xFF3E1C1C),
        background: const Color(0xFF101713),
        surface: const Color(0xFF1C2921),
        border: const Color(0xFF405348),
        textPrimary: const Color(0xFFF7FAF8),
        textSecondary: const Color(0xFFCAD8CF),
      );
    }

    return AppPalette(
      brightness: Brightness.light,
      accent: main,
      accentDark: deep,
      accentTint: tint,

      success: const Color(0xFF116B35),
      successTint: const Color(0xFFE0F2E6),

      info: const Color(0xFF075A9B),
      infoTint: const Color(0xFFE2F0FA),

      amber: const Color(0xFF754000),
      amberTint: const Color(0xFFFFEAC2),

      red: const Color(0xFFAC1717),
      redTint: const Color(0xFFFFE4E4),

      // Cleaner backgrounds and stronger text contrast.
      background: const Color(0xFFF5F8F6),
      surface: const Color(0xFFFFFFFF),
      border: const Color(0xFFD1DDD5),

      textPrimary: const Color(0xFF17231B),
      textSecondary: const Color(0xFF4B5B50),
    );
  }
}
