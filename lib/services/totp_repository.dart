import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:f2fa/utils/utils.dart';
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
    getLogger().info('totps length: ${_localTotps.length}');
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
    //异步同步数据
    _sync(false);
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
          : WebdavException(httpcode: -1, errMsg: e.toString()),
    );
  }

  Future<bool> _mergeData(List<Totp> rtotps) async {
    if (_localTotps.isEmpty) {
      _localTotps = rtotps;
      _ls.saveTotpList(_localTotps);
      return false;
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

        //本地较新，如果不是彻底删除状态，就以本地为准
        if (localTotp.updatedAt > remoteTotp.updatedAt) {
          if (localTotp.isDirty && localTotp.deleteStatus == 2) {
            mergedMap.remove(localTotp.id);
          } else {
            mergedMap[localTotp.id] = localTotp;
          }
          diffFlag = true;
        } else if (remoteTotp.deleteStatus == 2) {
          //如果是彻底删除状态，移除
          mergedMap.remove(localTotp.id);
          diffFlag = true;
        }
      }
    }

    _localTotps = mergedMap.values.toList();

    //这里保存的是脏数据，同步成功后会更新脏数据标志
    await _ls.saveTotpList(_localTotps);
    return diffFlag;
  }

  List<Totp> _filterDeleted() {
    return _localTotps.where((totp) => totp.deleteStatus == 0).toList();
  }

  Future<void> _sync(bool forceUpload) async {
    if (_ongoingSync != null) {
      return;
    }

    _ongoingSync = _doSync(forceUpload);
    await _ongoingSync;
    _ongoingSync = null;
  }

  Future<void> _doSync(bool forceUpload) async {
    try {
      final rdata = await _webdav?.getData();
      if (rdata == null) {
        return;
      }
      // 远程数据为空，本地有数据，则上传
      // 远程数据没有变化，本地有变化，上传
      // 远程数据有变化，合并后上传
      if ((rdata.status == GetDataStatus.empty && _localTotps.isNotEmpty) ||
          (rdata.status == GetDataStatus.notModified && forceUpload) ||
          (rdata.status == GetDataStatus.modified &&
              await _mergeData(rdata.data!))) {
        await _doPutData();
        _setWebdavError(null);
      }
    } catch (e) {
      getLogger().error('sync error $e');
      _setWebdavError(e);
    }
  }

  Future<void> _doPutData() async {
    final cleanData = List<Totp>.from(_localTotps);
    cleanData.removeWhere((element) => element.deleteStatus == 2); //移除删除状态为2的
    await _webdav?.putData(
      cleanData.map((e) => e.copyWith(isDirty: false)).toList(),
    );
    //同步成功后，刷新脏数据标志，并将彻底删除的移除
    _localTotps.removeWhere((e) => e.deleteStatus == 2);
    _localTotps = _localTotps.map((e) => e.copyWith(isDirty: false)).toList();
    // 重新保存干净的数据
    await _ls.saveTotpList(_localTotps);
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
    totp = totp.copyWith(
      isDirty: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
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
              createdAt: DateTime.now().millisecondsSinceEpoch,
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
        _localTotps.add(
          totp.copyWith(createdAt: DateTime.now().millisecondsSinceEpoch),
        );
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

  // Future<void> clearRecycleBin() async {
  //   _localTotps = _localTotps.map((totp) {
  //     if (totp.deleteStatus == 1) {
  //       return totp.copyWith(
  //         deleteStatus: 2,
  //         isDirty: true,
  //         updatedAt: DateTime.now().millisecondsSinceEpoch,
  //       );
  //     }
  //     return totp;
  //   }).toList();
  //   await _ls.saveTotpList(_localTotps);
  //   _sync(true);
  // }

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

  Future<List<Totp>> getAllTotps() async {
    return _localTotps;
  }

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

    if (await _mergeData(imported)) {
      _doPutData();
    }
    _streamController.add(_localTotps);
  }

  void dispose() {
    _streamController.close();
    _webdavSyncController.close();
  }
}
