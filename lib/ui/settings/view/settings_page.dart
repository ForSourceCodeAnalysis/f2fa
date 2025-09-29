import 'dart:async';
import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/settings/view/deleted_list_page.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:f2fa/theme/theme.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:totp_repository/totp_repository.dart';
import 'webdav_config_form.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo packinfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final p = await PackageInfo.fromPlatform();
    setState(() {
      packinfo = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.cSettings.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        children: [
          // Appearance card (inline controls)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.palette, color: colorTheme.primary),
                    title: Text(
                      LocaleKeys.spAppearance.tr(),
                      style: TextStyle(
                        color: colorTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: const SizedBox.shrink(),
                  ),
                  const Divider(height: 1),
                  // Theme mode + color + language in a compact row when wide
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // Theme Mode
                        Row(
                          children: [
                            Expanded(child: Text(LocaleKeys.spThemeMode.tr())),
                            SizedBox(
                              width: 180,
                              child: BlocBuilder<ThemeBloc, ThemeState>(
                                buildWhen: (p, c) => p.themeMode != c.themeMode,
                                builder: (context, state) =>
                                    DropdownButton<ThemeMode>(
                                      isExpanded: true,
                                      value: state.themeMode,
                                      items: ThemeMode.values.map((mode) {
                                        final map = {
                                          ThemeMode.system: LocaleKeys
                                              .spThemeModeSystem
                                              .tr(),
                                          ThemeMode.light: LocaleKeys
                                              .spThemeModeLight
                                              .tr(),
                                          ThemeMode.dark: LocaleKeys
                                              .spThemeModeDark
                                              .tr(),
                                        };
                                        return DropdownMenuItem(
                                          value: mode,
                                          child: Text(map[mode]!),
                                        );
                                      }).toList(),
                                      onChanged: (mode) {
                                        if (mode != null) {
                                          context.read<ThemeBloc>().add(
                                            ThemeModeChanged(mode),
                                          );
                                        }
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 4),
                        // Theme Color
                        Row(
                          children: [
                            Expanded(child: Text(LocaleKeys.spThemeColor.tr())),
                            SizedBox(
                              width: 180,
                              child: BlocBuilder<ThemeBloc, ThemeState>(
                                buildWhen: (p, c) =>
                                    p.themeColor != c.themeColor,
                                builder: (context, state) =>
                                    DropdownButton<ColorSeed>(
                                      isExpanded: true,
                                      value: state.themeColor,
                                      items: ColorSeed.values.map((color) {
                                        return DropdownMenuItem(
                                          value: color,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: color.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(color.label),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (color) {
                                        if (color != null) {
                                          context.read<ThemeBloc>().add(
                                            ThemeColorChanged(color),
                                          );
                                        }
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 4),
                        // Language
                        Row(
                          children: [
                            Expanded(child: Text(LocaleKeys.spLanguage.tr())),
                            SizedBox(
                              width: 180,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: context.locale.languageCode,
                                items: context.supportedLocales.map((locale) {
                                  return DropdownMenuItem(
                                    value: locale.languageCode,
                                    child: Text(
                                      context.tr(
                                        'languageName.${locale.languageCode}',
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (lang) {
                                  if (lang != null) {
                                    context.setLocale(Locale(lang));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sync card (navigates)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.cloud_sync, color: colorTheme.primary),
                  title: Text(
                    LocaleKeys.spSync.tr(),
                    style: TextStyle(
                      color: colorTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(LocaleKeys.spWebdav.tr()),

                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final localStorage = context.read<LocalStorageRepository>();
                    final webdav = await localStorage.getWebdavConfig();
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              WebDavConfigForm(initialWebdav: webdav),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Recycle
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.recycling_outlined,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    LocaleKeys.spRecycleBin.tr(),
                    style: TextStyle(
                      color: colorTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(LocaleKeys.spClearRecycleBin.tr()),
                  onTap: () async {
                    context.read<TotpRepository>().clearRecycleBin();
                    SnackBarWrapper.showSnackBar(
                      context: context,
                      message: LocaleKeys.spRecycleBinCleared.tr(),
                    );
                  },
                ),
                // const SizedBox(height: 4),
                ListTile(
                  title: Text(LocaleKeys.spRestoreRecycleBin.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeletedListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Feedback card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.forum_outlined,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    LocaleKeys.spFeedbackAndCommunity.tr(),
                    style: TextStyle(
                      color: colorTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(title: Text("QQ: 1683875916")),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // About card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorTheme.primary),
                  title: Text(
                    LocaleKeys.spAbout.tr(),
                    style: TextStyle(
                      color: colorTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    '${LocaleKeys.spVersion.tr()}: ${packinfo.version}',
                  ),
                ),
                ListTile(
                  title: Text(
                    '${LocaleKeys.spEmail.tr()}: jenken@12358134.xyz',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
