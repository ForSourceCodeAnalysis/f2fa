import 'package:f2fa/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // 联系方式数据
  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      type: ContactType.email,
      label: 'support@f2fa.com',
      icon: Icons.email,
      // color: Colors.blue,
    ),
    ContactMethod(
      type: ContactType.qq,
      label: '123456789',
      icon: FontAwesomeIcons.qq,
      // color: Colors.black,
    ),
    ContactMethod(
      type: ContactType.youtube,
      label: '@F2FA_Official',
      icon: FontAwesomeIcons.youtube,
      // color: Colors.red,
    ),
    ContactMethod(
      type: ContactType.bilibili,
      label: '@F2FA官方',
      icon: FontAwesomeIcons.bilibili,
      // color: Colors.blue,
    ),
    ContactMethod(
      type: ContactType.wechat,
      label: 'F2FA_Official',
      icon: Icons.wechat,
      // color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
            // 页面标题和描述
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
                    '反馈交流',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '欢迎反馈问题、建议或改进建议，我们会尽快回复您。',
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
                itemCount: _contactMethods.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final contact = _contactMethods[index];
                  return _ContactCard(
                    contact: contact,
                    onTap: () => _copyToClipboard(contact.label, context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制: $text'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

enum ContactType { email, qq, youtube, bilibili, wechat }

class ContactMethod {
  final ContactType type;
  final String label;
  final IconData icon;
  // final Color color;

  ContactMethod({
    required this.type,
    required this.label,
    required this.icon,
    // required this.color,
  });

  String get displayName {
    switch (type) {
      case ContactType.email:
        return 'Email';
      case ContactType.qq:
        return 'QQ';
      case ContactType.youtube:
        return 'YouTube';
      case ContactType.bilibili:
        return 'Bilibili';
      case ContactType.wechat:
        return 'WeChat';
    }
  }
}

class _ContactCard extends StatelessWidget {
  final ContactMethod contact;
  final VoidCallback onTap;

  const _ContactCard({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String getLocalizedLabel() {
      switch (contact.type) {
        case ContactType.email:
          return '邮箱';
        case ContactType.qq:
          return 'QQ';
        case ContactType.youtube:
          return 'YouTube';
        case ContactType.bilibili:
          return 'Bilibili';
        case ContactType.wechat:
          return 'WeChat';
      }
    }

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
                  color: theme.colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    contact.icon,
                    color: theme.colorScheme.secondary,
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
                      getLocalizedLabel(),
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
