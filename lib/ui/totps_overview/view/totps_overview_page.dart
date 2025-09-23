import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class TotpsOverviewPage extends StatelessWidget {
  const TotpsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TotpsOverviewBloc(totpRepository: context.read<TotpRepository>())
            ..add(TotpsOverviewSubscriptionRequested())
            ..add(TotpsOverviewTotpUpdated(true)),
      child: const TotpsOverviewView(),
    );
  }
}

class TotpsOverviewView extends StatefulWidget {
  const TotpsOverviewView({super.key});

  @override
  State<TotpsOverviewView> createState() => _TotpsOverviewViewState();
}

class _TotpsOverviewViewState extends State<TotpsOverviewView>
    with WidgetsBindingObserver {
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
          return CupertinoScrollbar(
            child: ReorderableListView.builder(
              itemCount: state.totps.length,
              itemBuilder: (context, index) {
                final totp = state.totps[index];
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
