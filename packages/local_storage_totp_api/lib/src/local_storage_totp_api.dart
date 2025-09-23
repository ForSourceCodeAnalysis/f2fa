import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_api/totp_api.dart';
import 'package:otp/otp.dart';
import 'package:webdav_sync/webdav_sync.dart';

class LocalStorageTotpApi extends TotpApi {
  LocalStorageTotpApi._();

  late final LocalStorageRepository _lsr; //本地存储
  late final WebdavSync? _webdavsync;

  List<Totp> _localTotps = [];

  static Future<LocalStorageTotpApi> instance(
      LocalStorageRepository lsr) async {
    final l = LocalStorageTotpApi._();
    await l._init(lsr);

    return l;
  }

  Future<void> _init(LocalStorageRepository lsr) async {
    _lsr = lsr;
    _loadLocalData();
    webdavInit();
  }

  Future<void> webdavInit() async {
    final webdav = _lsr.getWebdavConfig();
    if (webdav == null) {
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

      //同步远程数据
      _sync(false);
    } catch (e) {
      _webdavsync = null;
      await _lsr.saveWebdavErrorInfo(e.toString());
    }
  }

  Future<void> mergeData(List<Totp> rtotps) async {
    if (_localTotps.isEmpty) {
      _localTotps = rtotps;
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
      if (!mergedMap.containsKey(localTotp.id)) {
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
      //删除超过30天的彻底删除
      final now = DateTime.now().millisecondsSinceEpoch;
      if (mergedMap[localTotp.id]!.deletedAt != 0 &&
          now - mergedMap[localTotp.id]!.deletedAt >= 30 * 24 * 3600 * 1000) {
        mergedMap.remove(localTotp.id);
        diffFlag = true;
      }
    }

    // 将合并后的结果转换为列表
    _localTotps = mergedMap.values.toList();

    await _lsr.saveTotpList(_localTotps);
    if (diffFlag) {
      await _webdavsync?.syncToServer(_localTotps);
    }
  }

  List<Totp> filterDeleted() {
    return _localTotps.where((totp) => totp.deletedAt == 0).toList();
  }

  void _loadLocalData() {
    final totps = _lsr.getTotpList();
    if (totps == null) {
      return;
    }

    _localTotps = totps;
  }

  Future<void> _sync(bool forceUpload) async {
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
        await mergeData(rdata.data!);
        await _lsr.clearWebdavErrorInfo();
        return;
      }
      //远程数据没有变化，本地有变化
      if (rdata.status == GetDataStatus.notModified && forceUpload) {
        await _webdavsync?.syncToServer(_localTotps);
        await _lsr.clearWebdavErrorInfo();
      }
    } catch (e) {
      _lsr.saveWebdavErrorInfo(e.toString());
    }
  }

  @override
  Future<List<Totp>> getTotpList() => Future.value(filterDeleted());

  @override
  Future<void> saveTotp(Totp totp) async {
    final index = _localTotps.indexWhere((i) => i.id == totp.id);
    if (index >= 0) {
      _localTotps[index] = totp;
    } else {
      _localTotps.add(totp);
    }

    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }

  @override
  Future<void> deleteTotp(String id) async {
    final index = _localTotps.indexWhere((totp) => totp.id == id);
    if (index < 0) {
      return;
    }
    _localTotps[index] = _localTotps[index].copyWith(
      deletedAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }

  @override
  void refreshCode() {
    _localTotps = _localTotps.map((t) {
      if (t.deletedAt != 0) {
        return t;
      }
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
    final deleted = _localTotps.where((totp) => totp.deletedAt != 0).toList();
    _localTotps = [...totps, ...deleted];

    await _lsr.saveTotpList(_localTotps);
    _sync(true);
  }
}
