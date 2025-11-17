import 'package:f2fa/app.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _initTalkerLogger();
  final ls = await LocalStorage.instance();
  GetIt.I.registerSingleton<LocalStorage>(ls);

  final repository = await TotpRepository.instance();
  runApp(App(totpRepository: repository));
}

void _initTalkerLogger() {
  final talker = TalkerFlutter.init(
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        level: kDebugMode ? LogLevel.debug : LogLevel.warning,
      ),
      formatter: CustomLoggerFormatter(),
    ),
    settings: TalkerSettings(
      colors: <String, AnsiPen>{TalkerKey.debug: AnsiPen()..magenta()},
    ),
  );
  GetIt.I.registerSingleton<Talker>(talker);
  talker.info('talker init complete');
}
