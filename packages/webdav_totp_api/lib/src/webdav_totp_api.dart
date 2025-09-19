import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:totp_api/totp_api.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';
import 'package:path/path.dart';

class WebdavTotpApi {
  WebdavTotpApi._({
    required this.url,
    required this.username,
    required this.password,
    this.encryptKey,
    // this.overwrite,
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
      // overwrite: overwrite,
    );
    await api._init();
    return api;
  }

  late final String url;
  late final String username;
  late final String password;
  late final String? encryptKey;
  // late final bool? overwrite;

  late final Client _client;
  late final Encrypter _encrypter;
  late final IV _iv;
  late final String _filepath;

  Future<void> _init() async {
    Uri uri = Uri.parse(url);
    final host = '${uri.scheme}://${uri.host}';
    _filepath = join(uri.path, 'f2fa.db');
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
  }

  Future<String> getData(DateTime? lastModified) async {
    late final List<int> bytes;
    try {
      if (lastModified != null) {
        _client.setHeaders({
          'If-Modified-Since': lastModified.toIso8601String(),
        });
      }
      bytes = await _client.read(_filepath);
    } catch (e) {
      final ex = e as DioException;
      if (ex.response?.statusCode == 404) {
        final emptyData = _encrypt(jsonEncode([]));
        await _client.write(_filepath, utf8.encode(emptyData));
        return '[]';
      } else {
        throw const WebDAVException(WebDAVErrorType.connectError);
      }
    }
    if (bytes.isEmpty) {
      return '[]';
    }

    try {
      final encryptedData = utf8.decode(bytes);
      final decryptedData = _decrypt(encryptedData);
      return decryptedData;
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

  Future<void> syncToServer(List<Totp> totps) async {
    final jsonData = jsonEncode(totps.map((t) => t.toJson()).toList());

    final encryptedData = _encrypt(jsonData);

    _client.write(
      _filepath,
      utf8.encode(encryptedData),
    );
  }
}
