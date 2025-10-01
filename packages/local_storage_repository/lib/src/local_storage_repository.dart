import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:local_storage_repository/src/models/webdav_status.dart';
import 'package:rxdart/rxdart.dart';

class LocalStorageRepository {
  LocalStorageRepository._();

  static Future<LocalStorageRepository> instance() async {
    final inst = LocalStorageRepository._();
    await inst._init();
    return inst;
  }

  static const String _boxname = 'f2fadb';
  static const String _webdavConfigKey = "webdavconfig";
  static const String _webdavErrKey = "webdaverrorinfo";
  static const String _totpListKey = "totplist";
  static const String _webdavLastModifiedKey = "webdavlastmodified";
  static const String _webdavEtagKey = "webdavetag";
  static const String _localEncryptKeyKey = "localencryptkey";

  final _syncStatusController = BehaviorSubject<WebdavStatus>.seeded(
    const WebdavStatus(),
  );

  Stream<WebdavStatus> getSyncStatus() =>
      _syncStatusController.asBroadcastStream();

  late final Box _box;
  late final String _localEncryptKey;
  late final Encrypter _encrypter;
  late final IV _iv;
  late final FlutterSecureStorage _secureStorage;
  late final WebdavConfig? _webdavConfig;
  WebdavStatus _webdavStatus = const WebdavStatus();

  WebdavConfig? get webdavConfig => _webdavConfig;

  Future<void> _init() async {
    _box = await Hive.openBox(_boxname);
    _secureStorage = const FlutterSecureStorage();
    _localEncryptKey =
        await _secureStorage.read(key: _localEncryptKeyKey) ??
        _generateLocalEncryptKey();
    _encrypter = _createEncrypter(_localEncryptKey);
    _webdavConfig = await _getWebdavConfig();

    if (_webdavConfig != null) {
      _webdavStatus = _webdavStatus.copyWith(
        configured: true,
        errorInfo: getWebdavErrorInfo(),
      );
      _syncStatusController.add(_webdavStatus);
    }
  }

  String _generateLocalEncryptKey() {
    final key = Key.fromSecureRandom(32); // 256 bits
    final keyString = base64UrlEncode(key.bytes);
    _secureStorage.write(key: _localEncryptKeyKey, value: keyString);
    return keyString;
  }

  Encrypter _createEncrypter(String encryptKey) {
    final keyBytes = sha256.convert(utf8.encode(encryptKey)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));
    _iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  String _encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String _decrypt(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  Future<WebdavConfig?> _getWebdavConfig() async {
    final wjson = await _secureStorage.read(key: _webdavConfigKey);
    if (wjson == null || wjson.isEmpty) {
      return null;
    } else {
      final jsonMap = Map<String, dynamic>.from(jsonDecode(wjson));
      return WebdavConfig.fromJson(jsonMap);
    }
  }

  Future<void> saveWebdavConfig(WebdavConfig webdavConfig) async {
    await _secureStorage.write(
      key: _webdavConfigKey,
      value: jsonEncode(webdavConfig.toJson()),
    );
    _webdavStatus = _webdavStatus.copyWith(configured: true);
    _syncStatusController.add(_webdavStatus);
  }

  Future<void> clearWebdavConfig() async {
    await _secureStorage.delete(key: _webdavConfigKey);
    _webdavStatus = _webdavStatus.copyWith(configured: false);
    _syncStatusController.add(_webdavStatus);
  }

  List<Totp>? getTotpList() {
    final tjson = _box.get(_totpListKey);
    if (tjson == null) {
      return null;
    }
    final tjsonDecrypted = _decrypt(tjson);
    final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(
      jsonDecode(tjsonDecrypted),
    );
    return jsonList
        .map((e) => Totp.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveTotpList(List<Totp> totpList) async {
    await _box.put(
      _totpListKey,
      _encrypt(jsonEncode(totpList.map((e) => e.toJson()).toList())),
    );
  }

  DateTime? getWebdavLastModified() {
    final dt = _box.get(_webdavLastModifiedKey);
    return dt == null ? null : DateTime.parse(dt);
  }

  Future<void> saveWebdavLastModified(DateTime lastModified) async {
    await _box.put(_webdavLastModifiedKey, lastModified.toIso8601String());
  }

  Future<void> clearWebdavLastModified() async {
    await _box.delete(_webdavLastModifiedKey);
  }

  String? getWebdavErrorInfo() {
    return _box.get(_webdavErrKey);
  }

  Future<void> saveWebdavErrorInfo(String errorInfo) async {
    await _box.put(_webdavErrKey, errorInfo);
    _webdavStatus = _webdavStatus.copyWith(errorInfo: errorInfo);
    _syncStatusController.add(_webdavStatus);
  }

  Future<void> clearWebdavErrorInfo() async {
    await _box.delete(_webdavErrKey);
    _webdavStatus = _webdavStatus.copyWith(errorInfo: '');
    _syncStatusController.add(_webdavStatus);
  }

  String? getWebdavEtag() {
    return _box.get(_webdavEtagKey);
  }

  Future<void> saveWebdavEtag(String etag) async {
    await _box.put(_webdavEtagKey, etag);
  }

  Future<void> clearWebdavEtag() async {
    await _box.delete(_webdavEtagKey);
  }
}
