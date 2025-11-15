import 'package:f2fa/blocs/blocs.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) =>
          DeletedRestoreBloc(context.read<TotpRepository>())
            ..add(const DeletedRestoreInit()),
      child: BlocConsumer<DeletedRestoreBloc, DeletedRestoreState>(
        listener: (context, state) {},
        builder: (context, state) {
          return PageLoader(
            isLoading: state.status == DeletedRestoreStatus.loading,
            child: Scaffold(
              appBar: AppBar(
                title: Text(al.rbpAppbarTitle),
                actions: [
                  IconButton(
                    onPressed: () => _showClearAllConfirmation(context),
                    icon: const Icon(Icons.delete_forever),
                  ),
                ],
              ),
              body: state.totps.isEmpty
                  ? Center(child: Text(al.rbpEmptyItemsTips))
                  : _buildDeletedList(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeletedList(BuildContext context) {
    final state = context.read<DeletedRestoreBloc>().state;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: state.totps.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final totp = state.totps[index];
          return _DeletedTotpTile(
            totp: totp,
            onRestore: () => context.read<DeletedRestoreBloc>().add(
              DeletedRestoreRestore(totp.id),
            ),
            onDeletePermanently: () => context.read<DeletedRestoreBloc>().add(
              DeletedRestoreDeletePermanently(totp.id),
            ),
          );
        },
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context) {
    final al = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(al.rbpClearAllDialogTitle),
        content: Text(al.rbpClearAllDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(al.rbpClearAllDialogCancelBtn),
          ),
          FilledButton(
            onPressed: () {
              // TODO: clear all
            },
            child: Text(al.rbpClearAllDialogConfirmBtn),
          ),
        ],
      ),
    );
  }
}

class _DeletedTotpTile extends StatelessWidget {
  final Totp totp;
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;

  const _DeletedTotpTile({
    required this.totp,
    required this.onRestore,
    required this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final al = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issuer and Account
            Row(
              children: [
                // Icon placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      totp.issuer.isNotEmpty
                          ? totp.issuer[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totp.issuer,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totp.account,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestore,
                    icon: Icon(
                      Icons.restore,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(al.rbpRestoreBtn),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onDeletePermanently,
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: Text(al.rbpDelPermanentlyBtn),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
