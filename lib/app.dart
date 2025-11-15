import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/router/routes.dart';
import 'package:f2fa/services/services.dart';
import 'package:f2fa/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class App extends StatelessWidget {
  const App({required this.totpRepository, super.key});

  final TotpRepository totpRepository;

  @override
  Widget build(BuildContext context) {
    final ls = GetIt.I<LocalStorage>();

    return RepositoryProvider.value(
      value: totpRepository,
      child: StreamBuilder(
        stream: ls.settingsBox.watch(),
        builder: (context, snapshot) {
          final tl = ls.themeLanguage;
          getLogger().info(
            'current theme: ${tl.themeName},current locale: ${tl.locale}',
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme(themeName: ls.currentThemeName).light(),
            darkTheme: AppTheme(themeName: ls.currentThemeName).dark(),
            themeMode: tl.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(tl.locale),
            routerConfig: approuter,
          );
        },
      ),
    );
  }
}
