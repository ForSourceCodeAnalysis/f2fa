import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/services/services.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

Talker getLogger() {
  return GetIt.I.get<Talker>();
}

AppLocalizations getLocaleInstance() {
  final locale = GetIt.I.get<LocalStorage>().themeLanguage.locale;
  switch (locale) {
    case 'zh':
      return AppLocalizationsZh();
    default:
      return AppLocalizationsEn();
  }
}
