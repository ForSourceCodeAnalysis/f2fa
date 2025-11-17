import 'package:f2fa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final card = Theme.of(context).cardTheme;
    return TalkerScreen(
      appBarTitle: 'Logs',
      talker: getLogger(),
      theme: TalkerScreenTheme(
        backgroundColor: color.surface,
        textColor: text.bodyMedium?.color ?? color.onSurface,
        cardColor: card.color ?? color.surface,
        logColors: {TalkerKey.debug: Colors.green},
      ),
    );
  }
}
