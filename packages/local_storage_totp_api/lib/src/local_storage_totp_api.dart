import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_api/totp_api.dart';
import 'package:otp/otp.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';

class LocalStorageTotpApi extends TotpApi {
  LocalStorageTotpApi._();

  static final LocalStorageTotpApi _instance = LocalStorageTotpApi._();
  static bool isInitialized = false;
  static const String _storageKey = 'totpliststr';
  static late final LocalStorageRepository _localStorageRepository;
  static late final WebdavTotpApi _webdavapi;
  static DateTime? _lastModified = null;

  static List<Totp> _totps = [];
  static List<Totp> _localTotps = [];

  static Future<LocalStorageTotpApi> getInstance() async {
    if (!isInitialized) {
      _localStorageRepository = await LocalStorageRepository.getInstance();
      isInitialized = true;
      final lm = _localStorageRepository.box.get('lastModified') ?? '';
      _lastModified = lm.isEmpty ? null : DateTime.parse(lm);
      _loadLocalData();
      webdavInit();
      mergeData();
    }
    return _instance;
  }

  static Future<void> webdavInit() async {
    final webdav = _localStorageRepository.getWebdavConfig();
    if (webdav == null) {
      return;
    }

    try {
      _webdavapi = await WebdavTotpApi.instance(
        url: webdav.url,
        username: webdav.username,
        password: webdav.password,
        encryptKey: webdav.encryptKey,
        overwrite: true,
      );
      await _localStorageRepository.box
          .delete(LocalStorageRepository.webdavErrKey);
    } catch (e) {
      final WebDAVErrorType errType;
      if (e is WebDAVException) {
        errType = e.type;
      } else {
        errType = WebDAVErrorType.unknownError;
      }
      await _localStorageRepository.box
          .put(LocalStorageRepository.webdavErrKey, errType.name);
    }
  }

  static Future<void> mergeData() async {
    String tstr = '';
    try {
      //获取远程数据
      tstr = await _webdavapi.getData(_lastModified ?? null);
      await _localStorageRepository.box
          .delete(LocalStorageRepository.webdavErrKey);
    } catch (e) {
      final WebDAVErrorType errType;
      if (e is WebDAVException) {
        errType = e.type;
      } else {
        errType = WebDAVErrorType.unknownError;
      }
      await _localStorageRepository.box
          .put(LocalStorageRepository.webdavErrKey, errType.name);
    }

    final remotetotps = parseFromJson(tstr);

    if (remotetotps.isEmpty) {
      return;
    }
    if (_localTotps.isEmpty) {
      _localTotps = remotetotps;
      filterDeleted();
      return;
    }

    final Map<String, Totp> mergedMap = {};

    for (final remoteTotp in remotetotps) {
      mergedMap[remoteTotp.id] = remoteTotp;
    }

    // 遍历本地项目
    for (final localTotp in _localTotps) {
      // 如果远程数据中没有该项目，添加它
      if (!mergedMap.containsKey(localTotp.id)) {
        mergedMap[localTotp.id] = localTotp;
      } else {
        // 如果两边都有该项目，删除时间优先 比较更新时间，保留更新的版本
        final remoteTotp = mergedMap[localTotp.id]!;

        if (localTotp.updatedAt > remoteTotp.updatedAt) {
          mergedMap[localTotp.id] = localTotp;
        }
      }
      //删除超过7天的彻底删除
      final now = DateTime.now().millisecondsSinceEpoch;
      if (mergedMap[localTotp.id]!.deletedAt != 0 &&
          now - mergedMap[localTotp.id]!.deletedAt >= 7 * 24 * 3600 * 1000) {
        mergedMap.remove(localTotp.id);
      }
    }

    // 将合并后的结果转换为列表
    _localTotps = mergedMap.values.toList();
    filterDeleted();
    if (!listEquals(_localTotps, remotetotps)) {
      _webdavapi.syncToServer(_localTotps);
    }
  }

  static void filterDeleted() {
    _totps = _localTotps.where((totp) => totp.deletedAt == 0).toList();
  }

  static void _loadLocalData() {
    final totpsJson = _localStorageRepository.box.get(_storageKey);
    if (totpsJson == null) {
      return;
    }
    _localTotps = parseFromJson(totpsJson);
    filterDeleted();
  }

  static List<Totp> parseFromJson(String json) {
    if (json.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(
      jsonDecode(json),
    ).map((el) => Totp.fromJson(el)).toList();
  }

  @override
  Future<List<Totp>> getTotpList() => Future.value(_totps);

  @override
  Future<void> saveTotp(Totp totp) async {
    // final totps = [..._totps];
    final index = _totps.indexWhere((i) => i.id == totp.id);
    if (index >= 0) {
      _totps[index] = totp;
    } else {
      _totps.add(totp);
      _localTotps.add(totp);
    }

    _localStorageRepository.box.put(_storageKey, jsonEncode(_localTotps));
    _webdavapi.syncToServer(_localTotps);
  }

  @override
  Future<void> deleteTotp(String id) async {
    // final totps = [..._totps];
    final index = _totps.indexWhere((totp) => totp.id == id);
    if (index < 0) {
      return;
    }

    _totps.removeAt(index);
    for (int i = 0; i < _localTotps.length; i++) {
      if (_localTotps[i].id == id) {
        final now = DateTime.now().millisecondsSinceEpoch;
        _localTotps[i] =
            _localTotps[index].copyWith(deletedAt: now, updatedAt: now);
      }
    }

    _localStorageRepository.box.put(_storageKey, jsonEncode(_localTotps));
    _webdavapi.syncToServer(_localTotps);
  }

  @override
  List<Totp> refreshCode() {
    return _totps.map((t) {
      final code = OTP.generateTOTPCodeString(
        t.secret,
        DateTime.now().millisecondsSinceEpoch,
        interval: t.period,
        length: t.digits,
        algorithm: Algorithm.values.byName(t.algorithm.toUpperCase()),
        isGoogle: true,
      );
      final remaining = OTP.remainingSeconds();

      return t.copyWith(
        remaining: remaining,
        code: code,
      );
    }).toList();
  }

  @override
  Future<void> reorderTotps(List<Totp> totps) async {
    _totps = totps;
    final deleted = _localTotps.where((totp) => totp.deletedAt != 0).toList();
    _localTotps = [...totps, ...deleted];

    await _localStorageRepository.box.put(_storageKey, jsonEncode(_localTotps));
    _webdavapi.syncToServer(_localTotps);
  }
}
