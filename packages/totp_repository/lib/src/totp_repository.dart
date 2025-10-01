import 'dart:io';
import 'dart:convert';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:otp/otp.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webdav_sync/webdav_sync.dart';

class TotpRepository {
  TotpRepository._();

  late final _streamController = BehaviorSubject<List<Totp>>.seeded(const []);

  Stream<List<Totp>> getTotps() => _streamController.asBroadcastStream();

  late final LocalStorageRepository _lsr; //本地存储
  WebdavSync? _webdavsync;

  List<Totp> _localTotps = [];
  Future<void>? _ongoingSync;

  static Future<TotpRepository> instance(LocalStorageRepository lsr) async {
    final t = TotpRepository._();
    await t._init(lsr);
    return t;
  }

  Future<void> _init(LocalStorageRepository lsr) async {
    _lsr = lsr;
    _loadLocalData();
    _streamController.add(_filterDeleted());
    _webdavInit();
  }

  Future<void> _webdavInit() async {
    final webdav = await _lsr.getWebdavConfig();
    if (webdav == null) {
      _webdavsync = null;
      _lsr.clearWebdavErrorInfo();
      return;
    }
    try {
      _webdavsync = await WebdavSync.instance(
        url: webdav.url,
        username: webdav.username,
        password: webdav.password,
        encryptKey: webdav.encryptKey,
        lsr: _lsr,
      );

      await _sync(false);
    } catch (e) {
      _webdavsync = null;
      await _lsr.saveWebdavErrorInfo(e.toString());
    }
  }

  Future<void> _mergeData(List<Totp> rtotps) async {
    if (_localTotps.isEmpty) {
      _localTotps = rtotps;
      _lsr.saveTotpList(_localTotps);
      return;
    }

    final Map<String, Totp> mergedMap = {};

    for (final remoteTotp in rtotps) {
      mergedMap[remoteTotp.id] = remoteTotp;
    }
    bool diffFlag = false;
    // 遍历本地项目
    for (final localTotp in _localTotps) {
      // 如果远程数据中没有该项目，添加它
      if (!mergedMap.containsKey(localTotp.id) && localTotp.deleteStatus != 2) {
        mergedMap[localTotp.id] = localTotp;
        diffFlag = true;
      } else {
        // 如果两边都有该项目, 比较更新时间，保留更新的版本
        final remoteTotp = mergedMap[localTotp.id]!;

        if (localTotp.updatedAt > remoteTotp.updatedAt) {
          mergedMap[localTotp.id] = localTotp;
          diffFlag = true;
        }
      }
    }
    //删除超过1年彻底删除
    final now = DateTime.now().millisecondsSinceEpoch;
    _localTotps = mergedMap.values
        .where((totp) => !(now - totp.updatedAt >= 365 * 24 * 3600 * 1000 &&
            totp.deleteStatus == 2))
        .toList();

    await _lsr.saveTotpList(_localTotps);
    if (diffFlag) {
      await _webdavsync?.syncToServer(_localTotps);
    }
  }

  List<Totp> _filterDeleted() {
    return _localTotps.where((totp) => totp.deleteStatus == 0).toList();
  }

  void _loadLocalData() {
    final totps = _lsr.getTotpList();
    if (totps == null) {
      return;
    }

    _localTotps = totps;
  }

  Future<void> _sync(bool forceUpload) async {
    // serialize concurrent sync attempts: if one is ongoing, await it
    if (_ongoingSync != null) {
      await _ongoingSync!;
      return;
    }

    _ongoingSync = _doSync(forceUpload);
    try {
      await _ongoingSync;
    } finally {
      _ongoingSync = null;
    }
  }

  Future<void> _doSync(bool forceUpload) async {
    try {
      final rdata = await _webdavsync?.getData();
      if (rdata == null) {
        return;
      }
      //数据为空，本地有数据，则上传
      if (rdata.status == GetDataStatus.empty && _localTotps.isNotEmpty) {
        await _webdavsync?.syncToServer(_localTotps);
        await _lsr.clearWebdavErrorInfo();
        return;
      }
      if (rdata.status == GetDataStatus.modified) {
        await _mergeData(rdata.data!);
        await _lsr.clearWebdavErrorInfo();
        return;
      }
      //远程数据没有变化，本地有变化
      if (rdata.status == GetDataStatus.notModified && forceUpload) {
        await _webdavsync?.syncToServer(_localTotps);
        await _lsr.clearWebdavErrorInfo();
        return;
      }
      await _lsr.clearWebdavErrorInfo();
    } catch (e) {
      _lsr.saveWebdavErrorInfo(e.toString());
    }
  }

  int existIndex(String id, {String? oldId}) {
    return _localTotps.indexWhere((totp) => totp.id == id && totp.id != oldId);
  }

  Future<void> saveTotp(Totp totp, {Totp? oldTotp}) async {
    int index = -1;
    if (oldTotp != null) {
      index = _localTotps.indexWhere((i) => i.id == oldTotp.id);
    }
    final eindex = existIndex(totp.id, oldId: oldTotp?.id);

    if (index >= 0) {
      //更新
      if (totp.id != oldTotp?.id) {
        if (eindex >= 0) {
          //id不同，且存在重复的，更新重复的，删除旧的
          _localTotps[eindex] = totp;
          //不能直接删除，否则同步时会判断出错
          _localTotps[index] = _localTotps[index].copyWith(
            deleteStatus: 1,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
        } else {
          //id不同，且不重复
          _localTotps[index] = totp;
          _localTotps.add(oldTotp!.copyWith(
            deleteStatus: 1,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      } else {
        //id相同
        _localTotps[index] = totp;
      }
    } else {
      if (eindex >= 0) {
        //需要覆盖已存在的
        _localTotps[eindex] = totp;
      } else {
        //新增
        _localTotps.add(totp);
      }
    }

    await _lsr.saveTotpList(_localTotps);
    await _sync(true);
    _streamController.add(_filterDeleted());
  }

  Future<void> deleteTotp(String id) async {
    final index = _localTotps.indexWhere((totp) => totp.id == id);
    if (index < 0) {
      return;
    }
    _localTotps[index] = _localTotps[index].copyWith(
      deleteStatus: 1,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _lsr.saveTotpList(_localTotps);
    _sync(true);
    _streamController.add(_filterDeleted());
  }

  void refreshCode() {
    for (var i = 0; i < _localTotps.length; i++) {
      final t = _localTotps[i];
      if (t.deleteStatus != 0) continue;
      final code = OTP.generateTOTPCodeString(
        t.secret,
        DateTime.now().millisecondsSinceEpoch,
        interval: t.period,
        length: t.digits,
        algorithm: Algorithm.values.byName(t.algorithm.toUpperCase()),
        isGoogle: true,
      );
      final remaining = OTP.remainingSeconds(interval: t.period);
      _localTotps[i] = t.copyWith(remaining: remaining, code: code);
    }
    _streamController.add(_filterDeleted());
  }

  Future<void> reorderTotps(List<Totp> totps) async {
    final deleted =
        _localTotps.where((totp) => totp.deleteStatus != 0).toList();
    _localTotps = [...totps, ...deleted];

    await _lsr.saveTotpList(_localTotps);
    _sync(true);
    _streamController.add(_filterDeleted());
  }

  Future<void> clearRecycleBin() async {
    _localTotps = _localTotps.map((totp) {
      if (totp.deleteStatus == 1) {
        return totp.copyWith(deleteStatus: 2);
      }
      return totp;
    }).toList();
    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }

  Future<List<Totp>> getDeletedTotps() async {
    return _localTotps.where((totp) => totp.deleteStatus == 1).toList();
  }

  Future<void> restoreTotp(String id) async {
    final index = _localTotps.indexWhere((totp) => totp.id == id);
    if (index < 0) {
      return;
    }
    _localTotps[index] = _localTotps[index].copyWith(
      deleteStatus: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }

  Future<void> deletePermanently(String id) async {
    final index = _localTotps.indexWhere((totp) => totp.id == id);
    if (index < 0) return;

    _localTotps[index] = _localTotps[index].copyWith(
      deleteStatus: 2,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }

  /// Return all totps (including deleted ones) for export purposes.
  Future<List<Totp>> getAllTotps() async {
    return _localTotps;
  }

  /// Export totps as plaintext JSON into a file under [dir].
  /// Creates a file named totps_export_<timestamp>.json
  Future<String> exportTotpsPlain(String dir) async {
    final all = await getAllTotps();
    final jsonStr = jsonEncode(all.map((e) => e.toJson()).toList());
    final fname =
        'totps_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final path = Directory(dir);
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    final file = File('${path.path}/$fname');
    await file.writeAsString(jsonStr, flush: true);
    return file.path;
  }

  /// Import totps from a plaintext JSON file at [filePath].
  /// The file should contain a JSON array of totp objects.
  Future<void> importTotpsFromFile(String filePath) async {
    final f = File(filePath);
    if (!await f.exists()) {
      throw Exception('file not found');
    }
    final contents = await f.readAsString();
    final dynamic decoded = jsonDecode(contents);
    if (decoded is! List) {
      throw Exception('invalid format');
    }
    final List<Totp> imported = decoded
        .map((e) => Totp.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    await _mergeData(imported);
  }

  void dispose() {
    _streamController.close();
  }
}
