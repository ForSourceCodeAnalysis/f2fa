import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final class AppTheme {
  AppTheme({required this.themeName});
  final String themeName;

  static const subThemesData = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    sliderTrackHeight: 7,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    chipSchemeColor: SchemeColor.primary,
    chipSelectedSchemeColor: SchemeColor.secondary,
    alignedDropdown: true,
    drawerBackgroundSchemeColor: SchemeColor.primary,
    drawerSelectedItemSchemeColor: SchemeColor.primaryFixedDim,
    bottomSheetBackgroundColor: SchemeColor.secondary,
    bottomSheetModalBackgroundColor: null,
    bottomSheetRadius: 8.0,
    bottomSheetModalElevation: 20.0,
    bottomSheetClipBehavior: Clip.antiAlias,
    menuRadius: 25.0,
    menuElevation: 18.0,
    menuSchemeColor: SchemeColor.error,
    menuOpacity: 0.45,
    menuPadding: EdgeInsetsDirectional.fromSTEB(8, 9, 12, 20),
    navigationBarSelectedIconSchemeColor: SchemeColor.secondaryContainer,
    navigationBarLabelBehavior:
        NavigationDestinationLabelBehavior.onlyShowSelected,
    navigationRailUseIndicator: true,
  );

  ThemeData light() {
    return FlexThemeData.light(
      // Using FlexColorScheme built-in FlexScheme enum based colors
      scheme: FlexScheme.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => FlexScheme.materialBaseline,
      ),
      // Component theme configurations for light mode.
      subThemesData: subThemesData,
      // Direct ThemeData properties.
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }

  ThemeData dark() {
    return FlexThemeData.dark(
      // Using FlexColorScheme built-in FlexScheme enum based colors.
      scheme: FlexScheme.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => FlexScheme.materialBaseline,
      ),
      // Component theme configurations for dark mode.
      subThemesData: subThemesData,
    );
  }
}
