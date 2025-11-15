import 'dart:convert';
import 'dart:math';

import 'package:f2fa/hive/hive_registrar.g.dart';
import 'package:f2fa/models/models.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/adapters.dart';

class LocalStorage {
  LocalStorage._();

  static Future<LocalStorage> instance() async {
    final inst = LocalStorage._();
    await inst._init();
    return inst;
  }

  static const String _boxname = 'f2fadb';
  static const String _localEncryptionKeyKey = "localencryptkey";
  static const String _totpsKey = "totps";
  static const String _webdavConfigKey = "webdavconfig";
  // static const String _webdavLastModifiedKey = "webdavlastmodified";
  // static const String _webdavEtagKey = "webdavetag";
  // static const String _webdavAuthMethodKey = "webdavauthmethod";

  static const String _settingsBoxname = 'settings';
  static const String themeLanguageKey = 'themelanguage';

  late final Box _box;
  late final Box _settingsBox;

  String _currentThemeName = '';

  String get currentThemeName => _currentThemeName;

  Box get settingsBox => _settingsBox;

  Future<void> _init() async {
    const secureStorage = FlutterSecureStorage();
    final localEncryptionKey = await secureStorage.read(
      key: _localEncryptionKeyKey,
    );

    if (localEncryptionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: _localEncryptionKeyKey,
        value: base64UrlEncode(key),
      );
    }
    final key = await secureStorage.read(key: _localEncryptionKeyKey);

    final encryptionKeyUint8List = base64Url.decode(key!);

    await Hive.initFlutter();
    Hive.registerAdapters();

    _box = await Hive.openBox(
      _boxname,
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );
    _settingsBox = await Hive.openBox(_settingsBoxname);
  }

  ThemeLanguage get themeLanguage {
    final tl = _settingsBox.get(themeLanguageKey);
    if (tl != null) {
      if (_currentThemeName.isNotEmpty) {
        return tl;
      }
      if (tl.themeName == 'random') {
        _currentThemeName =
            FlexScheme.values[Random().nextInt(FlexScheme.values.length)].name;
      } else {
        _currentThemeName = tl.themeName;
      }

      return tl;
    }
    //没有记录配置，初始化
    if (_currentThemeName.isEmpty) {
      _currentThemeName = FlexScheme.values[0].name;
    }
    return ThemeLanguage(
      themeMode: ThemeMode.light,
      themeName: _currentThemeName,
      locale: 'zh',
    );
  }

  Future<void> saveThemeLanguage(ThemeLanguage tl) async {
    if (tl.themeName != 'random') {
      _currentThemeName = tl.themeName;
    }
    await _settingsBox.put(themeLanguageKey, tl);
  }

  WebdavConfig? getWebdavConfig() {
    final WebdavConfig? webdavConfig = _box.get(_webdavConfigKey);
    return webdavConfig;
  }

  Future<void> saveWebdavConfig(WebdavConfig? webdavConfig) async {
    if (webdavConfig == null) {
      await _box.delete(_webdavConfigKey);
      return;
    }
    await _box.put(_webdavConfigKey, webdavConfig);
  }

  // DateTime? getWebdavLastModified() {
  //   final DateTime? dt = _box.get(_webdavLastModifiedKey);
  //   return dt;
  // }

  // Future<void> saveWebdavLastModified(DateTime? lastModified) async {
  //   if (lastModified == null) {
  //     await _box.delete(_webdavLastModifiedKey);
  //     return;
  //   }
  //   await _box.put(_webdavLastModifiedKey, lastModified);
  // }

  // String? getWebdavEtag() {
  //   return _box.get(_webdavEtagKey);
  // }

  // Future<void> saveWebdavEtag(String? etag) async {
  //   if (etag == null) {
  //     await _box.delete(_webdavEtagKey);
  //     return;
  //   }
  //   await _box.put(_webdavEtagKey, etag);
  // }

  // AuthMethod? getAuthMethod() {
  //   return _box.get(_webdavAuthMethodKey);
  // }

  // Future<void> saveAuthMethod(AuthMethod? authMethod) async {
  //   if (authMethod == null) {
  //     await _box.delete(_webdavAuthMethodKey);
  //     return;
  //   }
  //   await _box.put(_webdavAuthMethodKey, authMethod);
  // }

  List<Totp>? getTotpList() {
    final List<dynamic>? totps = _box.get(_totpsKey);
    return totps?.cast<Totp>();
  }

  Future<void> saveTotpList(List<Totp> totpList) async {
    await _box.put(_totpsKey, totpList);
  }
}
