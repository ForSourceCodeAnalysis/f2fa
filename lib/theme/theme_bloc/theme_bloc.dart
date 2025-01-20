import 'package:equatable/equatable.dart';
import 'package:f2fa/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<ThemeColorChanged>(_onThemeColorChanged);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.mode, themeColor: state.themeColor));
  }

  Future<void> _onThemeColorChanged(
    ThemeColorChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeColor: event.color, themeMode: state.themeMode));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final themeMode = json['themeMode'] as String;
    final themeColor = json['themeColor'] as String;
    return ThemeState(
        themeMode: ThemeMode.values.byName(themeMode),
        themeColor: ColorSeed.values.byName(themeColor));
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return <String, dynamic>{
      'themeMode': state.themeMode.name,
      'themeColor': state.themeColor.name,
    };
  }
}
