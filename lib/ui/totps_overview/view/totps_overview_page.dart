import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/totp_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class TotpsOverviewPage extends StatefulWidget {
  const TotpsOverviewPage({super.key});

  @override
  State<TotpsOverviewPage> createState() => _TotpsOverviewPageState();
}

class _TotpsOverviewPageState extends State<TotpsOverviewPage>
    with WidgetsBindingObserver {
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

  // Menu logic moved to reusable TotpMenuButton widget to avoid duplication.

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
    // Detect whether this route is the current/visible route in the navigator.
    // We do this here (lightweight) so we can pause/resume ticker updates when
    // the page is not the top-most route (e.g., the user navigated to another
    // page). This avoids needing a global RouteObserver.
    final route = ModalRoute.of(context);
    final routeIsCurrent = route?.isCurrent ?? true;
    if (routeIsCurrent != _isVisible) {
      _isVisible = routeIsCurrent;
      // Only enable updates if the app is also in resumed state.
      final appResumed =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      context.read<TotpsOverviewBloc>().add(
        TotpsOverviewTotpUpdated(routeIsCurrent && appResumed),
      );
    }
    return BlocListener<TotpsOverviewBloc, TotpsOverviewState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == TotpsOverviewStatus.failure) {
          SnackBarWrapper.showSnackBar(
            context: context,
            message: LocaleKeys.topErrorOccur.tr(),
          );
        }
      },
      child: BlocBuilder<TotpsOverviewBloc, TotpsOverviewState>(
        builder: (context, state) {
          if (state.totps.isEmpty) {
            if (state.status == TotpsOverviewStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == TotpsOverviewStatus.failure) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  LocaleKeys.topTapAdd.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          // Provide extra bottom padding so the floating action button doesn't
          // obscure the last item and users can always scroll it into view.
          const bottomPadding = 96.0;
          final width = MediaQuery.of(context).size.width;
          final isNarrow = width < 420;

          return CupertinoScrollbar(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: bottomPadding, top: 8),
              itemCount: state.totps.length,
              itemBuilder: (context, index) {
                final totp = state.totps[index];
                // print('totp: ${totp.issuer}, ${totp.account},index: $index');
                if (isNarrow) {
                  // compact two-line layout for small screens
                  return Card(
                    key: ValueKey(totp.id),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totp.issuer,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      totp.account,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              // small progress indicator
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: Stack(
                                  children: [
                                    CircularProgressIndicator(
                                      value: totp.remaining / totp.period,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withAlpha(24),
                                    ),
                                    Center(
                                      child: Text(
                                        totp.remaining.toString(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    totp.code,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontFamily: 'Monospace',
                                          letterSpacing: 2,
                                        ),
                                  ),
                                ),
                              ),
                              // menu aligned to row end, vertically under the countdown
                              TotpMenuButton(totp: totp),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // default (wide) layout uses existing list tile widget
                return TotpListTile(key: ValueKey(totp.id), totp: totp);
              },
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                context.read<TotpsOverviewBloc>().add(
                  TotpsOverviewReordered(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
