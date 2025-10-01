import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:f2fa/theme/theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:f2fa/ui/settings/view/webdav_config_form.dart';
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

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  _HomeViewState();

  WebdavConfig? _webdavConfig;
  StreamSubscription<String>? _syncSub;

  Future<void> _loadConfig() async {
    final repo = context.read<LocalStorageRepository>();
    final cfg = await repo.getWebdavConfig();
    if (!mounted) return;
    setState(() => _webdavConfig = cfg);
  }

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
  void initState() {
    super.initState();
    // load initial config
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfig();
      final repo = context.read<LocalStorageRepository>();
      _syncSub = repo.getSyncStatus().listen((s) {
        if (!mounted) return;
        // we only need to refresh the UI when sync status changes so we reload config
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    super.dispose();
  }

  Widget _buildStatusIcon() {
    final hasConfig = _webdavConfig != null;
    final webdavErr = context
        .read<LocalStorageRepository>()
        .getWebdavErrorInfo();

    Color color;
    bool showExclamation = false;
    if (!hasConfig) {
      color = Colors.grey;
    } else if (webdavErr != null && webdavErr.isNotEmpty) {
      color = Colors.red;
      showExclamation = true;
    } else {
      color = Colors.green;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.cloud_sync, color: color),
        if (showExclamation)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
          ),
      ],
    );
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
          // WebDAV sync status icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () async {
                // Open WebDAV edit page and refresh config after return
                final cfg = _webdavConfig;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebDavConfigForm(initialWebdav: cfg),
                  ),
                );
                if (!mounted) return;
                await _loadConfig();
              },
              child: _buildStatusIcon(),
            ),
          ),

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
