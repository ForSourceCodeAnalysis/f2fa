import 'package:f2fa/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:get_it/get_it.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(al.stpAppbarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildThemeModeSection(context),
                const SizedBox(height: 24),
                _buildThemeColorSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final ls = GetIt.I.get<LocalStorage>();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              al.stpThemeModeLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(al.stpThemeModeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(al.stpThemeModeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(al.stpThemeModeSystem),
                  icon: const Icon(Icons.auto_mode),
                ),
              ],
              selected: {ls.themeLanguage.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) async {
                if (newSelection.isNotEmpty) {
                  await ls.saveThemeLanguage(
                    ls.themeLanguage.copyWith(themeMode: newSelection.first),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeColorSection(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final ls = GetIt.I.get<LocalStorage>();
    final isRandom = ls.themeLanguage.themeName == 'random';
    final selectedScheme = ls.currentThemeName;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  al.stpThemeColorLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    Text(al.stpThemeRandomLabel),
                    Checkbox(
                      value: isRandom,
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        if (value) {
                          await ls.saveThemeLanguage(
                            ls.themeLanguage.copyWith(themeName: 'random'),
                          );
                        } else {
                          // 如果取消随机，保留当前主题
                          await ls.saveThemeLanguage(
                            ls.themeLanguage.copyWith(
                              themeName: selectedScheme,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isRandom)
              _buildColorSchemeSelector(context, selectedScheme)
            else
              Text(
                al.stpThemeRandomDesc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(175),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeSelector(
    BuildContext context,
    String selectedScheme,
  ) {
    final colorSchemes = FlexScheme.values
        .where((scheme) => scheme != FlexScheme.custom)
        .toList();
    final ls = GetIt.I.get<LocalStorage>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: colorSchemes.length,
          itemBuilder: (context, index) {
            final scheme = colorSchemes[index];
            final isSelected = scheme.name == selectedScheme;

            return _ColorSchemeCard(
              scheme: scheme,
              isSelected: isSelected,
              onTap: () async {
                await ls.saveThemeLanguage(
                  ls.themeLanguage.copyWith(themeName: scheme.name),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ColorSchemeCard extends StatelessWidget {
  const _ColorSchemeCard({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  final FlexScheme scheme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = FlexColor.schemes[scheme]?.light;
    if (colorScheme == null) {
      return const SizedBox();
    }

    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final tertiaryColor = colorScheme.tertiary;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: secondaryColor),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: tertiaryColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getSchemeDisplayName(scheme),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSchemeDisplayName(FlexScheme scheme) {
    // 将驼峰命名转换为可读的名称
    final name = scheme.name;
    final buffer = StringBuffer();

    for (int i = 0; i < name.length; i++) {
      if (i > 0 && name[i] == name[i].toUpperCase()) {
        buffer.write(' ');
      }
      buffer.write(name[i]);
    }

    final result = buffer.toString();
    return result[0].toUpperCase() + result.substring(1);
  }
}
