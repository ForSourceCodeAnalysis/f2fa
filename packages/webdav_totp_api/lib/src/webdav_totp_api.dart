import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:local_storage_totp_api/local_storage_totp_api.dart';
import 'package:totp_api/totp_api.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';

class WebdavTotpApi extends TotpApi {
  WebdavTotpApi._({
    required this.url,
    required this.username,
    required this.password,
    this.encryptKey,
    this.overwrite,
  });

  static Future<WebdavTotpApi> instance({
    required String url,
    required String username,
    required String password,
    String? encryptKey,
    bool? overwrite,
  }) async {
    final api = WebdavTotpApi._(
      url: url,
      username: username,
      password: password,
      encryptKey: encryptKey,
      overwrite: overwrite,
    );
    await api._init();
    return api;
  }

  late final String url;
  late final String username;
  late final String password;
  late final String? encryptKey;
  late final bool? overwrite;

  late final Client _client;
  late final Encrypter _encrypter;
  late final IV _iv;
  late final String _path;
  late final LocalStorageTotpApi _localTotpApi;

  Future<void> _init() async {
    Uri uri = Uri.parse(url);
    final host = '${uri.scheme}://${uri.host}';
    _path = uri.path;
    _client = newClient(
      host,
      user: username,
      password: password,
      debug: false,
    );

    // init encrypter
    if (encryptKey != null && encryptKey!.isNotEmpty) {
      final keyBytes = sha256.convert(utf8.encode(encryptKey!)).bytes;
      final key = Key(Uint8List.fromList(keyBytes));
      _iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));
      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    }

    await _loadData();
  }

  Future<void> _loadData() async {
    _localTotpApi = await LocalStorageTotpApi.getInstance();
    final localTotps = await _localTotpApi.getTotpList();
    late final List<int> bytes;
    try {
      bytes = await _client.read(_path);
    } catch (e) {
      throw const WebDAVException(WebDAVErrorType.connectError);
    }
    if (bytes.isEmpty) {
      if (localTotps.isEmpty) {
        return;
      }
      _syncToServer();
      return;
    }
    if (overwrite == null && localTotps.isNotEmpty) {
      throw const WebDAVException(WebDAVErrorType.overwriteError);
    }
    try {
      final encryptedData = utf8.decode(bytes);
      final decryptedData = _decrypt(encryptedData);

      await _localTotpApi.updateData(decryptedData);
    } catch (e) {
      throw const WebDAVException(WebDAVErrorType.parseError);
    }
  }

  String _encrypt(String data) {
    if (encryptKey == null || encryptKey!.isEmpty) {
      return data;
    }
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String _decrypt(String encryptedData) {
    if (encryptKey == null || encryptKey!.isEmpty) {
      return encryptedData;
    }
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  Future<List<Totp>> getTotpList() async {
    return _localTotpApi.getTotpList();
  }

  @override
  Future<void> saveTotp(Totp totp) async {
    await _localTotpApi.saveTotp(totp);
    _syncToServer();
  }

  @override
  Future<void> deleteTotp(String id) async {
    await _localTotpApi.deleteTotp(id);
    await _syncToServer();
  }

  @override
  List<Totp> refreshCode() {
    return _localTotpApi.refreshCode();
  }

  @override
  Future<void> reorderTotps(List<Totp> totps) async {
    await _localTotpApi.reorderTotps(totps);
    await _syncToServer();
  }

  Future<void> _syncToServer() async {
    final totps = await _localTotpApi.getTotpList();

    final jsonData = jsonEncode(totps.map((t) => t.toJson()).toList());

    final encryptedData = _encrypt(jsonData);

    _client.write(
      _path,
      utf8.encode(encryptedData),
    );
  }
}
