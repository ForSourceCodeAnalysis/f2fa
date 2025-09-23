import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:totp_api/totp_api.dart';
import 'package:webdav_sync/src/exception.dart';
import 'package:webdav_sync/src/model/get_data_res.dart';

class WebdavSync {
  WebdavSync._();

  static Future<WebdavSync> instance({
    required String url,
    required String username,
    required String password,
    String? encryptKey,
    required LocalStorageRepository lsr,
  }) async {
    final w = WebdavSync._();

    await w._init(
      url: url,
      username: username,
      password: password,
      encryptKey: encryptKey,
    );
    w._lsr = lsr;

    return w;
  }

  late final Encrypter? _encrypter;
  late final IV? _iv;
  late final Uri _filepath;
  late final WebDavStdClient _client;

  late final LocalStorageRepository _lsr;

  Future<void> _init({
    required String url,
    required String username,
    required String password,
    String? encryptKey,
  }) async {
    Uri uri = Uri.parse(url);

    // Ensure we don't produce a double-slash when url already ends with '/'
    final trimmedUrl = url.endsWith('/')
        ? url.substring(0, url.length - 1)
        : url;
    _filepath = Uri.parse('$trimmedUrl/f2fa.db');

    _client = WebDavClient.std();
    _client.addCredentials(
      uri,
      'webdav',
      HttpClientBasicCredentials(username, password),
    );
    late final WebDavStdResponse<WebDavStdResResultView>? response;
    // 连接验证
    try {
      final request = await _client.openUrl(
        method: WebDavMethod.propfind,
        url: _filepath,
        param: PropfindPropRequestParam(
          props: [PropfindRequestProp('displayname')],
        ),
      );

      response = await request.close();
    } catch (e) {
      throw WebDAVException(-1, msg: e.toString());
    }
    final httpres = response.response;

    if (httpres.statusCode == HttpStatus.unauthorized) {
      //认证失败
      final authHeader = httpres.headers.value(
        HttpHeaders.wwwAuthenticateHeader,
      );
      if (authHeader != null) {
        // Parse realm if present: realm="..."
        final realmReg = RegExp(
          r'realm\s*=\s*"?([^",]+)"?',
          caseSensitive: false,
        );
        final realmMatch = realmReg.firstMatch(authHeader);
        final realm = realmMatch?.group(1) ?? 'webdav';

        final ah = authHeader.toLowerCase();
        if (ah.contains('digest')) {
          // switch to Digest credentials
          _client.addCredentials(
            uri,
            realm,
            HttpClientDigestCredentials(username, password),
          );
        } else {
          throw WebDAVException(
            -1,
            msg:
                'This application does not support the authentication method of WebDAV service, please contact the developer to support.',
          );
        }
      }
    } else if (httpres.statusCode == HttpStatus.notFound) {
    } else if (httpres.statusCode >= HttpStatus.badRequest) {
      throw WebDAVException(httpres.statusCode);
    }
    // init encrypter
    if (encryptKey != null && encryptKey.isNotEmpty) {
      final keyBytes = sha256.convert(utf8.encode(encryptKey)).bytes;
      final key = Key(Uint8List.fromList(keyBytes));
      _iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));
      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    } else {
      _encrypter = null;
      _iv = null;
    }
  }

  Future<GetDataRes> getData() async {
    try {
      final request = await _client.dispatch(_filepath).get();
      final lastModified = _lsr.getWebdavLastModified();
      if (lastModified != null) {
        request.request.headers.set(
          HttpHeaders.ifModifiedSinceHeader,
          HttpDate.format(lastModified.toUtc()),
        );
      }
      final etag = _lsr.getWebdavEtag();
      if (etag != null) {
        request.request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final response = await request.close();
      final httpres = response.response;
      switch (httpres.statusCode) {
        case HttpStatus.notModified:
          return GetDataRes(status: GetDataStatus.notModified);
        case HttpStatus.notFound:
          await createFile();
          return GetDataRes(status: GetDataStatus.created);
        default:
          if (httpres.statusCode >= HttpStatus.badRequest) {
            throw WebDAVException(httpres.statusCode);
          }
          // Capture headers
          final contentType = response.response.headers.contentType;

          // Decide how to read the body: treat known binary media types as binary,
          // otherwise read as text via response.parse() and convert to bytes.
          final isBinary = contentType == null
              ? false
              : (contentType.mimeType == 'application/octet-stream' ||
                    contentType.mimeType.startsWith('image/') ||
                    contentType.mimeType.startsWith('audio/') ||
                    contentType.mimeType.startsWith('video/') ||
                    contentType.mimeType == 'application/pdf');
          List<int> bodyBytes;
          if (isBinary) {
            // Read raw bytes from underlying HttpClientResponse stream.
            final buffer = <int>[];
            await for (final chunk in response.response) {
              buffer.addAll(chunk);
            }
            bodyBytes = buffer;
          } else {
            // Textual response: use library parse() to decode and cache the body,
            // then convert to bytes using UTF-8.
            await response.parse();
            final bodyText = response.body ?? '';
            bodyBytes = utf8.encode(bodyText);
          }

          if (bodyBytes.isEmpty) {
            return GetDataRes(status: GetDataStatus.empty);
          }

          // Try to decode -> decrypt -> return

          final encryptedData = utf8.decode(bodyBytes);
          final decryptedData = _decrypt(encryptedData);
          final totps = List<Map<String, dynamic>>.from(
            jsonDecode(decryptedData),
          ).map((el) => Totp.fromJson(el)).toList();

          final lastmodifytime = httpres.headers.value(
            HttpHeaders.lastModifiedHeader,
          );
          final etag = httpres.headers.value(HttpHeaders.etagHeader);

          if (lastmodifytime != null) {
            try {
              final lm = HttpDate.parse(lastmodifytime);
              _lsr.saveWebdavLastModified(lm);
            } catch (_) {}
          }
          if (etag != null) {
            _lsr.saveWebdavEtag(etag);
          }

          return GetDataRes(data: totps, status: GetDataStatus.modified);
      }
    } catch (e) {
      if (e is WebDAVException) {
        rethrow;
      }
      throw WebDAVException(-1, msg: e.toString());
    }
  }

  Future<void> createFile() async {
    try {
      final reqeust = await _client.dispatch(_filepath).create(data: '');
      final response = await reqeust.close();
      final httpres = response.response;
      if (httpres.statusCode != HttpStatus.created) {
        throw WebDAVException(httpres.statusCode);
      }
    } catch (e) {
      if (e is WebDAVException) {
        rethrow;
      }
      throw WebDAVException(-1, msg: e.toString());
    }
  }

  String _encrypt(String data) {
    if (_encrypter == null) {
      return data;
    }
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String _decrypt(String encryptedData) {
    if (_encrypter == null) {
      return encryptedData;
    }
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  Future<void> syncToServer(List<Totp> totps) async {
    final jsonData = jsonEncode(totps.map((t) => t.toJson()).toList());
    final encryptedData = _encrypt(jsonData);
    // Minimal upload: create or overwrite the file with encrypted data
    try {
      final req = await _client.dispatch(_filepath).create(data: encryptedData);
      final res = await req.close();
      final httpres = res.response;
      if (httpres.statusCode >= HttpStatus.badRequest) {
        throw WebDAVException(res.response.statusCode);
      }
    } catch (e) {
      if (e is WebDAVException) {
        rethrow;
      }
      throw WebDAVException(-1, msg: e.toString());
    }
  }
}
