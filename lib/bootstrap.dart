import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:f2fa/app/app.dart';
import 'package:f2fa/generated/codegen_loader.g.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:local_storage_totp_api/local_storage_totp_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totp_api/totp_api.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';

void bootstrap() async {
  await EasyLocalization.ensureInitialized();

  // storage directory
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final dataDir = Directory('${documentsDirectory.path}/f2fa');
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }

  Hive.init(dataDir.path);

  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: dataDir);

  // Bloc.observer = const AppBlocObserver();

  final localStorageRepository = await LocalStorageRepository.getInstance();

  final repository =
      TotpRepository(totpApi: await getTotpApi(localStorageRepository));

  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: const <Locale>[
      Locale('en'),
      Locale('zh'),
    ],
    assetLoader: const CodegenLoader(),
    fallbackLocale: const Locale('en'),
    useFallbackTranslations: true,
    saveLocale: true,
    startLocale: const Locale("zh"),
    child: App(
      totpRepository: repository,
      localStorageRepository: localStorageRepository,
    ),
  ));
}

Future<TotpApi> getTotpApi(LocalStorageRepository storage) async {
  final webdav = storage.getWebdavConfig();

  if (webdav != null) {
    try {
      final api = await WebdavTotpApi.instance(
        url: webdav.url,
        username: webdav.username,
        password: webdav.password,
        encryptKey: webdav.encryptKey,
        overwrite: true,
      );
      await storage.box.delete(LocalStorageRepository.webdavErrKey);
      return api;
    } catch (e) {
      final WebDAVErrorType errType;
      if (e is WebDAVException) {
        errType = e.type;
      } else {
        errType = WebDAVErrorType.unknownError;
      }
      await storage.box.put(LocalStorageRepository.webdavErrKey, errType.name);
    }
  }
  return await LocalStorageTotpApi.getInstance();
}
