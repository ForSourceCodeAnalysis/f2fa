import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
  Duration duration = const Duration(seconds: 2),
}) {
  final themeColor = Theme.of(context).colorScheme;
  final screenSize = MediaQuery.of(context).size;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: themeColor.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),

      behavior: behavior,
      duration: duration,
      backgroundColor: themeColor.surfaceContainerHighest,

      margin: EdgeInsets.only(
        bottom: screenSize.height * 2 / 3,
        left: screenSize.width / 4,
        right: screenSize.width / 4,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    ),
  );
}
