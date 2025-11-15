import 'package:flutter/material.dart';

class ThemeLanguage {
  ThemeLanguage({
    required this.themeMode,
    required this.themeName,
    required this.locale,
  });
  final ThemeMode themeMode;
  final String themeName;
  final String locale;

  ThemeLanguage copyWith({
    ThemeMode? themeMode,
    String? themeName,
    String? locale,
  }) => ThemeLanguage(
    themeMode: themeMode ?? this.themeMode,
    themeName: themeName ?? this.themeName,
    locale: locale ?? this.locale,
  );
}
