import 'package:easy_localization/easy_localization.dart';
import 'package:f2fa/generated/generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:totp_repository/totp_repository.dart';

class DeletedListPage extends StatelessWidget {
  const DeletedListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeletedRestoreBloc(context.read<TotpRepository>())
            ..add(const DeletedRestoreInit()),
      child: const _DeletedListView(),
    );
  }
}

class _DeletedListView extends StatelessWidget {
  const _DeletedListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.drpDeletedItems.tr())),
      body: BlocBuilder<DeletedRestoreBloc, DeletedRestoreState>(
        builder: (context, state) {
          if (state.status == DeletedRestoreStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == DeletedRestoreStatus.failure) {
            return Center(child: Text(state.error ?? 'Unknown Error'));
          } else if (state.status == DeletedRestoreStatus.success) {
            final totps = state.totps;
            if (totps == null || totps.isEmpty) {
              return Center(child: Text(LocaleKeys.drpEmpty.tr()));
            }
            return ListView.builder(
              itemCount: totps.length,
              itemBuilder: (context, index) {
                final totp = totps[index];
                String formatDeletedAt(dynamic v) {
                  if (v == null) return '';
                  DateTime? dt;
                  if (v is DateTime) {
                    dt = v;
                  } else if (v is int) {
                    dt = DateTime.fromMillisecondsSinceEpoch(v);
                  } else if (v is String) {
                    dt = DateTime.tryParse(v);
                  }
                  if (dt == null) return '';
                  final d = dt.toLocal();
                  String two(int n) => n.toString().padLeft(2, '0');
                  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
                }

                final issuer = totp.issuer;
                final name = totp.account;
                final deletedAt = formatDeletedAt(totp.updatedAt);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        child: Text(
                          (issuer.isNotEmpty
                                  ? issuer[0]
                                  : (name.isNotEmpty ? name[0] : '?'))
                              .toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (issuer.isNotEmpty) Text(issuer),
                          if (deletedAt.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  LocaleKeys.drpDeletedAt.tr(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  deletedAt,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: LocaleKeys.drpRestore.tr(),
                            onPressed: () {
                              context.read<DeletedRestoreBloc>().add(
                                DeletedRestoreRestore(totp.id),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            tooltip: LocaleKeys.drpDeletePermanently.tr(),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    LocaleKeys.drpDeletePermanently.tr(),
                                  ),
                                  content: Text(
                                    LocaleKeys.drpDeletePermanentlyTips.tr(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(LocaleKeys.cCancel.tr()),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(LocaleKeys.cDelete.tr()),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                context.read<DeletedRestoreBloc>().add(
                                  DeletedRestoreDeletePermanently(totp.id),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
