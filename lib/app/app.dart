import 'package:f2fa/ui/home/home.dart';
import 'package:f2fa/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class App extends StatelessWidget {
  const App({
    required this.totpRepository,
    required this.localStorageRepository,
    super.key,
  });

  final TotpRepository totpRepository;
  final LocalStorageRepository localStorageRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: totpRepository),
        RepositoryProvider.value(value: localStorageRepository),
      ],
      child: BlocProvider(
        create: (_) => ThemeBloc(),
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(
            color: state.themeColor,
            brightness: Brightness.light,
          ),
          darkTheme: AppTheme.getTheme(
            color: state.themeColor,
            brightness: Brightness.dark,
          ),
          themeMode: state.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const HomePage(),
        );
      },
    );
  }
}
