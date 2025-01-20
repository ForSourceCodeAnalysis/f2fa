import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class TotpListTile extends StatelessWidget {
  const TotpListTile({
    required this.totp,
    super.key,
  });

  final Totp totp;

  Color _getProgressColor(int remaining, int total) {
    final progress = remaining / total;
    if (progress > 0.5) {
      return Colors.green;
    } else if (progress > 0.25) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Left section (issuer & account)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totp.issuer,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  totp.account,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Middle section (code)
          Expanded(
            flex: 3,
            child: Text(
              totp.code,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'Monospace',
                letterSpacing: 2,
              ),
            ),
          ),
          // Right section (progress & menu)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: totp.remaining / totp.period,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: _getProgressColor(totp.remaining, totp.period),
                    ),
                    Center(
                      child: Text(
                        totp.remaining.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'copy':
                      Clipboard.setData(ClipboardData(text: totp.code));
                      SnackBarWrapper.showSnackBar(
                        context: context,
                        message: LocaleKeys.tltCodeCopied.tr(),
                      );
                      break;
                    case 'edit':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditTotpPage(initialTotp: totp),
                        ),
                      );
                      break;

                    case 'delete':
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(LocaleKeys.tltDeleteItem.tr()),
                          content: Text(LocaleKeys.tltDeleteConfirmAsk.tr()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(LocaleKeys.cCancel.tr()),
                            ),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<TotpRepository>()
                                    .deleteTotp(totp.id);
                                Navigator.pop(context);
                              },
                              child: Text(LocaleKeys.cConfirm.tr()),
                            ),
                          ],
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 8),
                        Text(LocaleKeys.tltCopyCode.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(LocaleKeys.cEdit.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        const SizedBox(width: 8),
                        Text(LocaleKeys.cDelete.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
