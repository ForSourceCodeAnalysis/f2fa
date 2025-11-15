import 'package:flutter/material.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/router/router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(al.spAppbarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSettingsSection(context, al, colorScheme, textTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AppLocalizations al,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final settingsItems = [
      _SettingsItem(
        icon: Icons.palette_outlined,
        title: al.spAppearanceLabel,
        onTap: () {
          const ThemeRoute().push(context);
        },
      ),
      _SettingsItem(
        icon: Icons.translate_outlined,
        title: al.spLanguageLabel,
        onTap: () {
          const LanguageRoute().push(context);
        },
      ),
      _SettingsItem(
        icon: Icons.sync_outlined,
        title: al.spSyncLabel,
        onTap: () {
          const WebdavRoute().push(context);
        },
      ),
      _SettingsItem(
        icon: Icons.import_export_outlined,
        title: al.spImportExportLabel,
        onTap: () {
          const ImportExportRoute().push(context);
        },
      ),
      _SettingsItem(
        icon: Icons.recycling_outlined,
        title: al.spRecycleBinLabel,
        onTap: () {
          const RecycleBinRoute().push(context);
        },
      ),

      _SettingsItem(
        icon: Icons.feedback_outlined,
        title: al.spFeedbackLabel,
        onTap: () {
          const FeedbackRoute().push(context);
        },
      ),
      _SettingsItem(
        icon: Icons.info_outlined,
        title: al.spAboutLabel,
        onTap: () {
          const AboutRoute().push(context);
        },
      ),
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          for (int i = 0; i < settingsItems.length; i++) ...[
            settingsItems[i],
            if (i < settingsItems.length - 1)
              Divider(
                height: 8,
                thickness: 1,
                indent: 72,
                endIndent: 24,
                color: colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),

      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),

      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurface.withAlpha(175),
      ),
      onTap: onTap,
    );
  }
}
