import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  // 联系方式数据
  List<ContactMethod> _getContactMethods(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return [
      ContactMethod(
        type: ContactType.email,
        label: 'support@f2fa.com',
        icon: Icons.email,
        displayName: al.fpEmail,
      ),
      ContactMethod(
        type: ContactType.qq,
        label: '123456789',
        icon: FontAwesomeIcons.qq,
        displayName: al.fpQQ,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contactMethods = _getContactMethods(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(al.fpAppbarTitle),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: .2),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    al.fpDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 联系方式列表
            Expanded(
              child: ListView.separated(
                itemCount: contactMethods.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final contact = contactMethods[index];
                  return _ContactCard(
                    contact: contact,
                    onTap: () => _copyToClipboard(context, contact.label),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    final al = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context: context, message: al.fpCopiedTips);
    }
  }
}

enum ContactType { email, qq, youtube, bilibili, wechat }

class ContactMethod {
  final ContactType type;
  final String label;
  final IconData icon;
  final String displayName;

  ContactMethod({
    required this.type,
    required this.label,
    required this.icon,
    required this.displayName,
  });
}

class _ContactCard extends StatelessWidget {
  final ContactMethod contact;
  final VoidCallback onTap;

  const _ContactCard({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 图标区域
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    contact.icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 内容区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 复制图标
              Icon(
                Icons.content_copy,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
