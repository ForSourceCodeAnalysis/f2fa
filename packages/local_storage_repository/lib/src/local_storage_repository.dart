import 'package:hive/hive.dart';
import 'package:local_storage_repository/local_storage_repository.dart';

class LocalStorageRepository {
  LocalStorageRepository._();

  static final LocalStorageRepository _instance = LocalStorageRepository._();
  static bool _isInitialized = false;

  static const String _boxname = 'f2faconfig';
  static const String webdavKey = "webdavconfig";
  static const String webdavErrKey = "webdaverrorinfo";

  static late final Box _box;

  static Future<LocalStorageRepository> getInstance() async {
    if (!_isInitialized) {
      await _init();
      _isInitialized = true;
    }
    return _instance;
  }

  static Future<void> _init() async {
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
}
