import 'dart:io';

import 'package:flutter/foundation.dart';

class Utils {
  static bool isAndroid() {
    return !kIsWeb && Platform.isAndroid;
  }

  static bool isIOS() {
    return !kIsWeb && Platform.isIOS;
  }

  static bool isMobile() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  static bool isDesktop() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isWindows() {
    return !kIsWeb && Platform.isWindows;
  }

  static bool isMacos() {
    return !kIsWeb && Platform.isMacOS;
  }

  static bool isLinux() {
    return !kIsWeb && Platform.isLinux;
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isNewVersion(String lastestVersion, String currentVersion) {
    final lll = lastestVersion.split('.');
    final ccc = currentVersion.split('.');
    lll[0] = lll[0].replaceFirst('v', '');
    for (var i = 0; i < 3; i++) {
      if (int.parse(lll[i]) > int.parse(ccc[i])) {
        return true;
      }
    }

    return false;
  }
}
