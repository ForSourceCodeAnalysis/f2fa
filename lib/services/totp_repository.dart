import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:f2fa/utils/util.dart';
import 'package:get_it/get_it.dart';
import 'package:otp/otp.dart';
import 'package:rxdart/rxdart.dart';

class TotpRepository {
  TotpRepository._();

  final _streamController = BehaviorSubject<List<Totp>>.seeded(const []);

  Stream<List<Totp>> getTotps() => _streamController.asBroadcastStream();

  final _webdavSyncController = BehaviorSubject<WebdavException?>.seeded(null);

  Stream<WebdavException?> getWebdavErrors() =>
      _webdavSyncController.asBroadcastStream();

  final LocalStorage _ls = GetIt.I.get<LocalStorage>(); //本地存储

  List<Totp> _localTotps = [];
  Webdav? _webdav;
  Future<void>? _ongoingSync;

  static Future<TotpRepository> instance() async {
    final t = TotpRepository._();
    await t._init();
    return t;
  }

  Future<void> _init() async {
    _localTotps = _ls.getTotpList() ?? [];
    _streamController.add(_filterDeleted());
    final wc = _ls.getWebdavConfig();
    if (wc == null ||
        wc.url.isEmpty ||
        wc.username.isEmpty ||
        wc.password.isEmpty ||
        wc.encryptKey.isEmpty) {
      return;
    }
    _webdav = Webdav(wc, _ls);

    _webdav!.checkResType().then(
      (value) {
        if (value) {
          //设置的是目录，同步数据
          _sync(false);
        } else {
          //设置的是文件
          _setWebdavError(
            WebdavException(errMsg: getLocaleInstance().webdavNotDir),
          );
        }
      },
      onError: (e) {
        _setWebdavError(e);
      },
    );
  }

  //设置同步错误
  void _setWebdavError(Object? e) {
    if (e == null) {
      _webdavSyncController.add(null);
      return;
    }
    _webdavSyncController.add(
      e is WebdavException
          ? e
          : WebdavException(
              httpcode: -1,
              errMsg: getLocaleInstance().webdavUnknownErr,
            ),
    );
  }

  Future<void> _mergeData(List<Totp> rtotps) async {
    if (_localTotps.isEmpty) {
      _localTotps = rtotps;
      _ls.saveTotpList(_localTotps);
      return;
    }

    final Map<String, Totp> mergedMap = {};

    for (final remoteTotp in rtotps) {
      mergedMap[remoteTotp.id] = remoteTotp;
    }
    bool diffFlag = false;
    // 遍历本地项目
    for (final localTotp in _localTotps) {
      // 如果远程数据中没有该项目，有两种情况
      // 1.本地创建的，未成功推送上去，只要状态不是彻底删除，都要保留
      // 2.远程数据已经删除了，本地未来得及更新，这种不处理
      if (!mergedMap.containsKey(localTotp.id)) {
        if (localTotp.isDirty && localTotp.deleteStatus != 2) {
          mergedMap[localTotp.id] = localTotp;
          diffFlag = true;
        }
      } else {
        // 如果两边都有该项目, 比较更新时间，保留更新的版本
        final remoteTotp = mergedMap[localTotp.id]!;
        if (localTotp.updatedAt > remoteTotp.updatedAt) {
          if (localTotp.isDirty && localTotp.deleteStatus == 2) {
            mergedMap.remove(localTotp.id);
          } else {
            mergedMap[localTotp.id] = localTotp;
          }
          diffFlag = true;
        } else if (remoteTotp.deleteStatus == 2) {
          mergedMap.remove(localTotp.id);
          diffFlag = true;
        }
      }
    }

    _localTotps = mergedMap.values.toList();

    await _ls.saveTotpList(_localTotps);
    if (diffFlag) {
      await _webdav?.putData(_localTotps);
      _setWebdavError(null);
    }
    _localTotps = _localTotps.map((e) => e.copyWith(isDirty: false)).toList();
  }

  List<Totp> _filterDeleted() {
    return _localTotps.where((totp) => totp.deleteStatus == 0).toList();
  }

  Future<void> _sync(bool forceUpload) async {
    if (_ongoingSync != null) {
      return;
    }
    try {
      _ongoingSync = _doSync(forceUpload);
      await _ongoingSync;
      final l = _localTotps.map((e) => e.copyWith(isDirty: false)).toList();
      _localTotps = l.where((e) => e.deleteStatus != 2).toList();
      await _ls.saveTotpList(_localTotps);
    } catch (e) {
      _setWebdavError(e);
    } finally {
      _ongoingSync = null;
    }
  }

  Future<void> _doSync(bool forceUpload) async {
    final rdata = await _webdav?.getData();
    if (rdata == null) {
      return;
    }
    //数据为空，本地有数据，则上传
    if (rdata.status == GetDataStatus.empty && _localTotps.isNotEmpty) {
      await _webdav?.putData(
        _localTotps.where((e) => e.deleteStatus != 2).toList(),
      );
      _setWebdavError(null);
      return;
    }
    if (rdata.status == GetDataStatus.modified) {
      await _mergeData(rdata.data!);
      _setWebdavError(null);
      return;
    }
    //远程数据没有变化，本地有变化
    if (rdata.status == GetDataStatus.notModified && forceUpload) {
      await _webdav?.putData(
        _localTotps.where((e) => e.deleteStatus != 2).toList(),
      );
      _setWebdavError(null);
      return;
    }
    _setWebdavError(null);
  }

  Future<void> forceSync() async {
    await _sync(true);
  }

  void changeWebdav(Webdav? webdav) {
    _webdav = webdav;
  }

  int existIndex(String id, {String? oldId}) {
    return _localTotps.indexWhere((totp) => totp.id == id && totp.id != oldId);
  }

  Future<void> saveTotp(Totp totp, {Totp? oldTotp}) async {
    totp = totp.copyWith(isDirty: true);
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
            isDirty: true,
          );
        } else {
          //id不同，且不重复
          _localTotps[index] = totp;
          _localTotps.add(
            oldTotp!.copyWith(
              deleteStatus: 1,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              isDirty: true,
            ),
          );
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

    await _ls.saveTotpList(_localTotps);
    _sync(true);
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
      isDirty: true,
    );
    await _ls.saveTotpList(_localTotps);
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
    final deleted = _localTotps
        .where((totp) => totp.deleteStatus != 0)
        .toList();
    _localTotps = [...totps, ...deleted];

    await _ls.saveTotpList(_localTotps);
    _sync(true);
    _streamController.add(_filterDeleted());
  }

  Future<void> clearRecycleBin() async {
    _localTotps = _localTotps.map((totp) {
      if (totp.deleteStatus == 1) {
        return totp.copyWith(deleteStatus: 2, isDirty: true);
      }
      return totp;
    }).toList();
    await _ls.saveTotpList(_localTotps);
    _sync(true);
  }

  List<Totp> getDeletedTotps() {
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
      isDirty: true,
    );
    await _ls.saveTotpList(_localTotps);
    _sync(true);
  }

  Future<void> deletePermanently(String id) async {
    final index = _localTotps.indexWhere((totp) => totp.id == id);
    if (index < 0) return;

    _localTotps[index] = _localTotps[index].copyWith(
      deleteStatus: 2,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDirty: true,
    );
    await _ls.saveTotpList(_localTotps);
    _sync(true);
  }

  Future<void> clearAllDeletedTotps() async {
    _localTotps = _localTotps.map((totp) {
      if (totp.deleteStatus == 1) {
        return totp.copyWith(deleteStatus: 2, isDirty: true);
      }
      return totp;
    }).toList();
    await _ls.saveTotpList(_localTotps);
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
