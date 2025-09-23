import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_api/totp_api.dart';

class LocalStorageRepository {
  LocalStorageRepository._();

  static Future<LocalStorageRepository> instance() async {
    final inst = LocalStorageRepository._();
    await inst._init();
    return inst;
  }

  static const String _boxname = 'f2faconfig';
  static const String webdavKey = "webdavconfig";
  static const String webdavErrKey = "webdaverrorinfo";
  static const String totpListKey = "totplist";
  static const String webdavLastModifiedKey = "webdavlastmodified";
  static const String webdavEtagKey = "webdavetag";

  late final Box _box;

  Future<void> _init() async {
    _box = await Hive.openBox(_boxname);
  }

  Box get box => _box;

  WebdavConfig? getWebdavConfig() {
    final wjson = _box.get(webdavKey);

    if (wjson == null) {
      return null;
    } else {
      final jsonMap = Map<String, dynamic>.from(wjson);
      return WebdavConfig.fromJson(jsonMap);
    }
  }

  Future<void> saveWebdavConfig(WebdavConfig webdavConfig) async {
    await _box.put(webdavKey, webdavConfig.toJson());
  }

  List<Totp>? getTotpList() {
    final tjson = _box.get(totpListKey);
    if (tjson == null) {
      return null;
    }
    final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(
      jsonDecode(tjson),
    );
    return jsonList
        .map((e) => Totp.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveTotpList(List<Totp> totpList) async {
    await _box.put(
      totpListKey,
      jsonEncode(totpList.map((e) => e.toJson()).toList()),
    );
  }

  DateTime? getWebdavLastModified() {
    final dt = _box.get(webdavLastModifiedKey);
    return dt == null ? null : DateTime.parse(dt);
  }

  Future<void> saveWebdavLastModified(DateTime lastModified) async {
    await _box.put(webdavLastModifiedKey, lastModified.toIso8601String());
  }

  String? getWebdavErrorInfo() {
    return _box.get(webdavErrKey);
  }

  Future<void> saveWebdavErrorInfo(String errorInfo) async {
    await _box.put(webdavErrKey, errorInfo);
  }

  Future<void> clearWebdavErrorInfo() async {
    await _box.delete(webdavErrKey);
  }

  String? getWebdavEtag() {
    return _box.get(webdavEtagKey);
  }

  Future<void> saveWebdavEtag(String etag) async {
    await _box.put(webdavEtagKey, etag);
  }
}
