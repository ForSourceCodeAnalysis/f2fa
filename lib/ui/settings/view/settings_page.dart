import 'dart:async';
import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:f2fa/theme/theme.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.cSettings.tr()),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _SettingsSection(
            title: LocaleKeys.spAppearance.tr(),
            children: [
              // Theme Mode
              ListTile(
                title: Text(LocaleKeys.spThemeMode.tr()),
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  buildWhen: (previous, current) =>
                      previous.themeMode != current.themeMode,
                  builder: (context, state) {
                    return DropdownButton<ThemeMode>(
                      value: state.themeMode,
                      items: ThemeMode.values.map((mode) {
                        final String m = {
                              ThemeMode.system:
                                  LocaleKeys.spThemeModeSystem.tr(),
                              ThemeMode.light: LocaleKeys.spThemeModeLight.tr(),
                              ThemeMode.dark: LocaleKeys.spThemeModeDark.tr(),
                            }[mode] ??
                            '';

                        return DropdownMenuItem(
                          value: mode,
                          child: Text(m),
                        );
                      }).toList(),
                      onChanged: (mode) {
                        if (mode != null) {
                          context.read<ThemeBloc>().add(ThemeModeChanged(mode));
                        }
                      },
                    );
                  },
                ),
              ),
              // Theme Color
              ListTile(
                title: Text(LocaleKeys.spThemeColor.tr()),
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  buildWhen: (previous, current) =>
                      previous.themeColor != current.themeColor,
                  builder: (context, state) {
                    return DropdownButton<ColorSeed>(
                      value: state.themeColor,
                      items: ColorSeed.values.map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
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
                          context
                              .read<ThemeBloc>()
                              .add(ThemeColorChanged(color));
                        }
                      },
                    );
                  },
                ),
              ),
              // Language
              ListTile(
                title: Text(LocaleKeys.spLanguage.tr()),
                trailing: DropdownButton<String>(
                  value: context.locale.toString(),
                  items: context.supportedLocales.map((locale) {
                    return DropdownMenuItem(
                      value: locale.languageCode,
                      child: Text(
                        context.tr('languageName.${locale.languageCode}'),
                      ),
                    );
                  }).toList(),
                  onChanged: (locale) {
                    if (locale != null) {
                      context.setLocale(Locale(locale));
                    }
                  },
                ),
              ),
            ],
          ),
          // Sync Section
          _SettingsSection(
            title: LocaleKeys.spSync.tr(),
            children: [
              // WebDAV
              ListTile(
                title: Text(LocaleKeys.spWebdav.tr()),
                subtitle: Text(LocaleKeys.spWebdavSubtitle.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final localStorage = context.read<LocalStorageRepository>();
                  final webdav = localStorage.getWebdavConfig();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WebDavConfigForm(
                      initialWebdav: webdav,
                    ),
                  ));
                },
              ),
            ],
          ),
          // About Section
          _SettingsSection(
            title: LocaleKeys.spAbout.tr(),
            children: [
              ListTile(
                title: Text(LocaleKeys.spVersion.tr()),
                trailing: Text(packinfo.version),
                onTap: () {
                  final localStorage = context.read<LocalStorageRepository>();
                  final webdav = localStorage.getWebdavConfig();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WebDavConfigForm(
                      initialWebdav: webdav,
                    ),
                  ));
                },
              ),
              ListTile(
                title: const Text("Github"),
                trailing: const Text("https://github.com/jenken827/f2fa"),
                onTap: () {
                  Clipboard.setData(const ClipboardData(
                      text: "https://github.com/jenken827/f2fa"));
                  SnackBarWrapper.showSnackBar(
                    context: context,
                    message: LocaleKeys.spProjectAddressCopied.tr(),
                  );
                },
              ),
              ListTile(
                title: const Text('Gitee'),
                trailing: const Text("https://gitee.com/jenken827/f2fa"),
                onTap: () {
                  Clipboard.setData(const ClipboardData(
                      text: "https://gitee.com/jenken827/f2fa"));
                  SnackBarWrapper.showSnackBar(
                    context: context,
                    message: LocaleKeys.spProjectAddressCopied.tr(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}
