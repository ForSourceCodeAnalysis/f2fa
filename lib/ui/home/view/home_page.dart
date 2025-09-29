import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:f2fa/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TotpsOverviewBloc(totpRepository: context.read<TotpRepository>())
            ..add(TotpsOverviewSubscriptionRequested())
            ..add(TotpsOverviewTotpUpdated(true)),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _scanQR(BuildContext context) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (!context.mounted || res == null) {
      return;
    }

    final t = Totp.parseFromUrl(res);
    if (t == null) {
      SnackBarWrapper.showSnackBar(
        context: context,
        message: LocaleKeys.hpInvalidQR.tr(),
      );

      return;
    }
    try {
      await context.read<TotpRepository>().saveTotp(t);
    } catch (e) {
      if (context.mounted) {
        SnackBarWrapper.showSnackBar(
          context: context,
          message: LocaleKeys.hpAddFail.tr(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((ThemeBloc bloc) => bloc.state.themeMode);
    final isLightMode = switch (themeMode) {
      ThemeMode.system =>
        View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light,
      ThemeMode.light => true,
      ThemeMode.dark => false,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('F2FA'),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeBloc>().add(
              ThemeModeChanged(isLightMode ? ThemeMode.dark : ThemeMode.light),
            ),
            icon: isLightMode
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: const TotpsOverviewPage(),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'scan') {
            _scanQR(context);
          } else if (result == 'manual') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RepositoryProvider.value(
                  value: context.read<TotpRepository>(),
                  child: const EditTotpPage(),
                ),
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: "scan",
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner),
                const SizedBox(width: 8),
                Text(LocaleKeys.hpScanAdd.tr()),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'manual',
            child: Row(
              children: [
                const Icon(Icons.create_rounded),
                const SizedBox(width: 8),
                Text(LocaleKeys.hpManAdd.tr()),
              ],
            ),
          ),
        ],
        child: const FloatingActionButton(
          shape: CircleBorder(),
          onPressed: null,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
