import 'package:flutter/material.dart';

class SnackBarWrapper {
  static void showSnackBar(
      {required BuildContext context,
      required String message,
      SnackBarBehavior behavior = SnackBarBehavior.floating,
      Duration duration = const Duration(seconds: 2)}) {
    final themeColor = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: themeColor.onSurface),
        ),
        behavior: behavior,
        duration: duration,
        backgroundColor: themeColor.surface,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height / 2,
          left: MediaQuery.of(context).size.width / 4,
          right: MediaQuery.of(context).size.width / 4,
        ),
      ),
    );
  }
}
