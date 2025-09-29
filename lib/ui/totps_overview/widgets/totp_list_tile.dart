import 'package:flutter/material.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'totp_menu.dart';

class TotpListTile extends StatelessWidget {
  const TotpListTile({required this.totp, super.key});

  final Totp totp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wide layout: single-row presentation where code takes most space.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // left: issuer + account
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(totp.issuer, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(totp.account, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // center: code (larger area)
            Expanded(
              flex: 4,
              child: Center(
                child: Text(
                  totp.code,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Monospace',
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // right: progress + menu
            SizedBox(
              width: 72,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: totp.remaining / totp.period,
                          backgroundColor: theme.colorScheme.onPrimary
                              .withAlpha(24),
                          // color: _getProgressColor(totp.remaining, totp.period),
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
                  const SizedBox(width: 8),
                  TotpMenuButton(totp: totp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
