import 'package:f2fa/blocs/blocs.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/pages/home/totp_list_tile.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:f2fa/router/router.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TotpsOverviewBloc(totpRepository: context.read<TotpRepository>())
            ..add(TotpsOverviewSubscriptionRequested())
            ..add(TotpsOverviewTotpUpdated(true))
            ..add(TotpsOverviewWebdavStatusSubscribe()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _scanQR(BuildContext context) async {
    final al = AppLocalizations.of(context)!;
    final res = await const ScannerRoute().push(context);

    if (!context.mounted || res == null) {
      return;
    }

    final t = Totp.parseFromUrl(res);
    if (t == null) {
      showSnackBar(context: context, message: al.hpInvalidQRCodeErrMsg);

      return;
    }
    await context.read<TotpRepository>().saveTotp(t);
  }

  Widget _buildStatusIcon(BuildContext context) {
    final webdavStatus = context.select(
      (TotpsOverviewBloc bloc) => bloc.state.webdavErr,
    );

    Color color;
    final isConfigured = GetIt.I.get<LocalStorage>().getWebdavConfig() != null;
    if (!isConfigured) {
      color = Colors.grey;
    } else if (webdavStatus?.errMsg.isNotEmpty ?? false) {
      color = Colors.red;
    } else {
      color = Colors.green;
    }

    return Icon(Icons.cloud_sync, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final ls = GetIt.I.get<LocalStorage>();
    final themeMode = ls.themeLanguage.themeMode;
    final isLightMode = switch (themeMode) {
      ThemeMode.system =>
        View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light,
      ThemeMode.light => true,
      ThemeMode.dark => false,
    };
    final al = AppLocalizations.of(context)!;
    final focus = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: al.hpSearchHintTxt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            focusNode: focus,
            onTapOutside: (event) => focus.unfocus(),

            onChanged: (query) {
              context.read<TotpsOverviewBloc>().add(
                TotpsOverviewSearchQueryChanged(query),
              );
            },
          ),
        ),
        actions: [
          // WebDAV sync status icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                const WebdavRoute().push(context);
              },
              child: _buildStatusIcon(context),
            ),
          ),

          IconButton(
            onPressed: () async => await ls.saveThemeLanguage(
              ls.themeLanguage.copyWith(
                themeMode: isLightMode ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
            icon: isLightMode
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              const SettingsRoute().push(context);
            },
          ),
        ],
      ),
      body: const _Totps(),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'scan') {
            _scanQR(context);
          } else if (result == 'manual') {
            const AddEditTotpRoute().push(context);
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: "scan",
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner),
                const SizedBox(width: 8),
                Text(al.hpPopMenuScanAdd),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'manual',
            child: Row(
              children: [
                const Icon(Icons.create_rounded),
                const SizedBox(width: 8),
                Text(al.hpPopMenuManAdd),
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

class _Totps extends StatefulWidget {
  const _Totps();

  @override
  State<_Totps> createState() => _TotpsState();
}

class _TotpsState extends State<_Totps> with WidgetsBindingObserver {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<TotpsOverviewBloc>().add(TotpsOverviewTotpUpdated(true));
    } else {
      context.read<TotpsOverviewBloc>().add(TotpsOverviewTotpUpdated(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final routeIsCurrent = route?.isCurrent ?? true;
    if (routeIsCurrent != _isVisible) {
      _isVisible = routeIsCurrent;
      final appResumed =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      context.read<TotpsOverviewBloc>().add(
        TotpsOverviewTotpUpdated(routeIsCurrent && appResumed),
      );
    }
    final al = AppLocalizations.of(context)!;
    return BlocBuilder<TotpsOverviewBloc, TotpsOverviewState>(
      builder: (context, state) {
        // 添加搜索过滤
        final filteredTotps = state.searchQuery.isEmpty
            ? state.totps
            : state.totps.where((totp) {
                final query = state.searchQuery.toLowerCase();
                return totp.issuer.toLowerCase().contains(query) ||
                    totp.account.toLowerCase().contains(query);
              }).toList();

        if (filteredTotps.isEmpty) {
          if (state.status == TotpsOverviewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == TotpsOverviewStatus.failure) {
            return const SizedBox();
          }
          return Center(
            child: Text(
              state.searchQuery.isEmpty
                  ? al.hpEmptyListTips
                  : al.hpNoMatchItemsTips,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        return CupertinoScrollbar(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96, top: 8),
            itemCount: filteredTotps.length,
            itemBuilder: (context, index) {
              final totp = filteredTotps[index];
              return TotpListTile(key: ValueKey(totp.id), totp: totp);
            },
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              context.read<TotpsOverviewBloc>().add(
                TotpsOverviewReordered(oldIndex: oldIndex, newIndex: newIndex),
              );
            },
          ),
        );
      },
    );
  }
}
