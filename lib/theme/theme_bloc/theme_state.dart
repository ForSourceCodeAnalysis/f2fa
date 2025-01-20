part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState(
      {this.themeMode = ThemeMode.light,
      this.themeColor = ColorSeed.baseColor});

  /// The current theme mode.
  final ThemeMode themeMode;
  final ColorSeed themeColor;

  ThemeState copyWith({
    ThemeMode? themeMode,
    ColorSeed? themeColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  @override
  List<Object> get props => [themeMode, themeColor];
}
