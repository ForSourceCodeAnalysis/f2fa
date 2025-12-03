import 'package:f2fa/models/models.dart';
import 'package:flutter/material.dart';
import 'totp_menu.dart';

class TotpListTile extends StatelessWidget {
  const TotpListTile({required this.totp, required this.totpicon, super.key});

  final Totp totp;
  final Widget totpicon;

  Color _getProgressColor(int remaining, int period, ThemeData theme) {
    final ratio = remaining / period;
    if (ratio > 0.5) {
      return theme.colorScheme.primary;
    } else if (ratio > 0.2) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.error;
    }
  }

  // Widget _defaultIcon(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final issuerInitial = totp.issuer[0].toUpperCase();
  //   return Center(
  //     child: Text(
  //       issuerInitial,
  //       style: theme.textTheme.titleLarge?.copyWith(
  //         fontWeight: FontWeight.bold,
  //         color: theme.colorScheme.onPrimaryContainer,
  //       ),
  //     ),
  //   );
  // }

  // Future<Widget> _buildIcon(BuildContext context) async {
  //   static Map<String,Widget> iconCache = {};
  //   if (totp.icon.isEmpty) {
  //     return _defaultIcon(context);
  //   }
  //   getLogger().debug('loading icon: ${totp.icon}');
  //   final cacheKey = 'icon_${Uri.encodeComponent(totp.icon)}';
  //   if (totp.icon.endsWith('.svg')) {
  //     final file = await CacheManager(
  //       Config(
  //         cacheKey,
  //         stalePeriod: const Duration(days: 365),
  //         maxNrOfCacheObjects: 100,
  //       ),
  //     ).getSingleFile(totp.icon);
  //     return SvgPicture.file(file);
  //   } else {
  //     return CachedNetworkImage(
  //       imageUrl: totp.icon,
  //       placeholder: (context, url) => _defaultIcon(context),
  //       errorWidget: (context, url, error) => _defaultIcon(context),
  //       cacheManager: CacheManager(
  //         Config(
  //           cacheKey,
  //           stalePeriod: const Duration(days: 365),
  //           maxNrOfCacheObjects: 100,
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 图标
                Container(
                  width: 78,
                  height: 42,
                  decoration: BoxDecoration(
                    color: totp.icon.isNotEmpty
                        ? null
                        : theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: totpicon,
                ),

                Expanded(
                  child: Text(
                    totp.account,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          value: totp.remaining / totp.period,
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(
                              totp.remaining,
                              totp.period,
                              theme,
                            ),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      Center(
                        child: Text(
                          totp.remaining.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Issuer
                SizedBox(
                  width: 78,
                  child: Text(
                    totp.issuer,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Expanded(
                  child: Text(
                    totp.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TotpMenuButton(totp: totp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
