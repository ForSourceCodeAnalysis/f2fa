import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:f2fa/utils/utils.dart';
import 'package:path/path.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart';

class Webdav {
  Webdav(WebdavConfig wc, LocalStorage? localStorage)
    : _wc = wc,
      _ls = localStorage {
    _filepath = Uri.parse(join(wc.url, _fileName));
    _client = WebDavCustomClient()
      ..addCredentials(
        Uri.parse(_wc.url),
        'webdav',
        _wc.authMethod == AuthMethod.basic
            ? HttpClientBasicCredentials(_wc.username, _wc.password)
            : HttpClientDigestCredentials(_wc.username, _wc.password),
      );
    if (_wc.encryptKey.isNotEmpty) {
      final keyBytes = sha256.convert(utf8.encode(_wc.encryptKey)).bytes;
      final key = Key(Uint8List.fromList(keyBytes));
      _iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));
      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    } else {
      _encrypter = null;
      _iv = null;
    }
  }

  final WebdavConfig _wc;
  late LocalStorage? _ls;
  late final WebDavCustomClient _client;
  static const String _fileName = 'f2fa.db';
  late final Uri _filepath;
  late final Encrypter? _encrypter;
  late final IV? _iv;

  Future<WebDavStdResponse> _propfind(Uri path) async {
    try {
      final request = await _client.openUrl(
        method: WebDavMethod.propfind,
        url: path,
        param: const PropfindPropRequestParam(
          props: [PropfindRequestProp.dav('resourcetype')],
          depth: Depth.resource,
        ),
      );

      final resp = await request.close();
      return resp;
    } catch (e) {
      getLogger().error('propfind error: $e');
      //这里的异常是连接异常，要么是网络问题，要么是URL错误
      throw WebdavException(
        httpcode: -1,
        errMsg: getLocaleInstance().webdavConnectErr,
      );
    }
  }

  //检查，包括连接性，认证，资源属性，如果是文件夹，返回true，否则返回false
  //需要设置到目录级，里面的文件由程序自动管理，方便扩展
  //有异常直接抛出
  Future<bool> checkResType() async {
    try {
      WebDavStdResponse response = await _propfind(Uri.parse(_wc.url));
      HttpClientResponse httpres = response.response;
      WebDavStdResResultView? result = await response.parse();

      //认证失败的情况下，尝试切换认证方式
      if (httpres.statusCode == HttpStatus.unauthorized) {
        getLogger().warning(
          'check credential failed, try to change auth method',
        );

        final authHeader = httpres.headers.value(
          HttpHeaders.wwwAuthenticateHeader,
        );
        //尝试切换认证方式
        if (authHeader != null) {
          getLogger().warning(
            'auth header is not null,parse realm,$authHeader',
          );
          // Parse realm if present: realm="..."
          final realmReg = RegExp(
            r'realm\s*=\s*"?([^",]+)"?',
            caseSensitive: false,
          );
          final realmMatch = realmReg.firstMatch(authHeader);
          final realm = realmMatch?.group(1) ?? 'webdav';

          final ah = authHeader.toLowerCase();
          if (ah.contains('digest') || ah.contains('basic')) {
            getLogger().info('change auth method to $ah');
            _client.addCredentials(
              Uri.parse(_wc.url),
              realm,
              ah.contains('basic')
                  ? HttpClientBasicCredentials(_wc.username, _wc.password)
                  : HttpClientDigestCredentials(_wc.username, _wc.password),
            );
            //重新发起请求
            response = await _propfind(Uri.parse(_wc.url));
            httpres = response.response;
            result = await response.parse();
            _wc.authMethod = ah.contains('basic')
                ? AuthMethod.basic
                : AuthMethod.digest;
          } else {
            throw WebdavException(
              errMsg: getLocaleInstance().webdavUnsupportedAuthMethod,
            );
          }
        } else {
          throw WebdavException(
            httpcode: HttpStatus.unauthorized,
            errMsg: getLocaleInstance().webdavAuthFailed,
          );
        }
      }
      if (httpres.statusCode == HttpStatus.unauthorized) {
        throw WebdavException(
          httpcode: httpres.statusCode,
          errMsg: getLocaleInstance().webdavAuthFailed,
        );
      } else if (httpres.statusCode == HttpStatus.notFound) {
        throw WebdavException(
          httpcode: httpres.statusCode,
          errMsg: getLocaleInstance().webdavResourceNotFound,
        );
      } else if (httpres.statusCode >= HttpStatus.badRequest) {
        throw WebdavException(
          httpcode: httpres.statusCode,
          errMsg: getLocaleInstance().webdavRequestFailed,
        );
      }

      final res = result as WebDavStdResponseResult?;

      getLogger().debug(res?.toDebugString() ?? 'res is null');
      getLogger().debug('url path : ${Uri.parse(_wc.url).path}');

      _ls?.saveWebdavConfig(_wc);

      final path = Uri.parse(_wc.url).path;
      final stdresource =
          res?.find(Uri.parse(path)) ?? res?.find(Uri.parse('$path/'));

      bool isDir = false;
      if (stdresource != null) {
        for (final prop in stdresource.props) {
          if (prop.name == 'resourcetype') {
            final vs = prop.value as ResourceTypes;
            if (vs.isNotEmpty) {
              isDir = true;
            }
            break;
          }
        }
      }

      return isDir;
    } catch (e) {
      getLogger().error(e);
      if (e is WebdavException) {
        rethrow;
      }
      throw WebdavException(httpcode: -1, errMsg: e.toString());
    }
  }

  void setLocalStorage(LocalStorage ls) {
    _ls = ls;
    _ls?.saveWebdavConfig(_wc);
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

  //拉取数据
  Future<GetDataRes> getData({bool force = false}) async {
    getLogger().info('lastModifyTime:${_wc.lastModified},etag:${_wc.etag}');
    try {
      final request = await _client.dispatch(_filepath).get();
      if (_wc.lastModified != null && !force) {
        request.request.headers.set(
          HttpHeaders.ifModifiedSinceHeader,
          HttpDate.format(_wc.lastModified!),
        );
      }
      if (_wc.etag != null && !force) {
        request.request.headers.set(HttpHeaders.ifNoneMatchHeader, _wc.etag!);
      }

      final response = await request.close();

      final httpres = response.response;
      if (httpres.statusCode == HttpStatus.notModified) {
        getLogger().info('not modified');
        return GetDataRes(status: GetDataStatus.notModified);
      }
      if (httpres.statusCode == HttpStatus.notFound) {
        getLogger().warning('file not found,create new file');
        await createFile();
        return GetDataRes(status: GetDataStatus.empty);
      }

      if (httpres.statusCode >= HttpStatus.badRequest) {
        throw WebdavException(
          httpcode: httpres.statusCode,
          errMsg: getLocaleInstance().webdavRequestFailed,
        );
      }
      final contentType = response.response.headers.contentType;
      final contentLength = response.response.headers.contentLength;

      getLogger().info('contentType: $contentType');
      final isBinary = contentType == null
          ? false
          : (contentType.mimeType == 'application/octet-stream' ||
                contentType.mimeType.startsWith('image/') ||
                contentType.mimeType.startsWith('audio/') ||
                contentType.mimeType.startsWith('video/') ||
                contentType.mimeType == 'application/pdf' ||
                contentLength >= 1024 * 1024); //大于1m的也作为二进制处理

      List<int> bodyBytes;
      if (isBinary) {
        final buffer = <int>[];
        await for (final chunk in response.response) {
          buffer.addAll(chunk);
        }
        bodyBytes = buffer;
      } else {
        await response.parse();
        final bodyText = response.body ?? '';
        bodyBytes = utf8.encode(bodyText);
      }
      final lmt = httpres.headers.value(HttpHeaders.lastModifiedHeader);
      final lastModified = lmt != null ? HttpDate.parse(lmt) : null;
      final et = httpres.headers.value(HttpHeaders.etagHeader);
      if (lastModified != null || et != null) {
        getLogger().debug('lastModified: $lastModified, etag: $et');
        _wc.lastModified = lastModified;
        _wc.etag = et;
        _ls?.saveWebdavConfig(_wc);
      }
      if (bodyBytes.isEmpty) {
        getLogger().info('empty body');
        return GetDataRes(status: GetDataStatus.empty);
      }
      final encryptedData = utf8.decode(bodyBytes);
      final decryptedData = _decrypt(encryptedData);
      getLogger().debug('decryptdata is $decryptedData');
      final totps = List<Map<String, dynamic>>.from(
        jsonDecode(decryptedData),
      ).map((el) => Totp.fromJson(el)).toList();

      return GetDataRes(status: GetDataStatus.modified, data: totps);
    } catch (e) {
      getLogger().error('get data failed,$e');
      if (e is WebdavException) {
        rethrow;
      }
      throw WebdavException(httpcode: -1, errMsg: e.toString());
    }
  }

  Future<void> createFile() async {
    try {
      final resp = await _client.dispatch(_filepath).create(data: '');

      final response = await resp.close();

      final httpres = response.response;
      if (httpres.statusCode != HttpStatus.created) {
        throw WebdavException(
          httpcode: httpres.statusCode,
          errMsg: getLocaleInstance().webdavCreateFileFailed,
        );
      }
    } catch (e) {
      getLogger().error('create file failed,$e');
      if (e is WebdavException) {
        rethrow;
      }
      throw WebdavException(httpcode: -1, errMsg: e.toString());
    }
  }

  Future<void> putData(List<Totp> totps) async {
    try {
      final jsonData = jsonEncode(totps.map((t) => t.toJson()).toList());
      final encryptedData = _encrypt(jsonData);

      final req = await _client.dispatch(_filepath).create(data: encryptedData);
      final response = await req.close();

      await response.parse();

      final httpClientResp = response.response;
      if (httpClientResp.statusCode >= HttpStatus.badRequest) {
        throw WebdavException(
          httpcode: httpClientResp.statusCode,
          errMsg: getLocaleInstance().webdavRequestFailed,
        );
      }
      _getModifiedTimeAndEtag();
      return;
    } catch (e) {
      getLogger().error('put data failed,$e');
      if (e is WebdavException) {
        rethrow;
      }
      throw WebdavException(httpcode: -1, errMsg: e.toString());
    }
  }

  Future<void> _getModifiedTimeAndEtag() async {
    try {
      final req = await _client
          .dispatch(Uri.parse(_wc.url))
          .findProps(
            props: const [
              PropfindRequestProp.dav("getlastmodified"),
              PropfindRequestProp.dav("getetag"),
            ],
          );

      final response = await req.close();

      final result = await response.parse();
      final res = result as WebDavStdResponseResult?;
      final stdresource = res?.find(Uri.parse(Uri.parse(_wc.url).path));
      if (stdresource == null) {
        return;
      }
      final props = stdresource.props;

      DateTime? lastModified;
      String? etag;

      for (final prop in props) {
        if (prop.name == 'getlastmodified' && prop.value != null) {
          final lastModifyTime = prop.value.toString();
          lastModified = DateTime.parse(lastModifyTime);
        }
        if (prop.name == 'getetag' && prop.value != null) {
          etag = prop.value.toString();
        }
      }
      if (lastModified != null || etag != null) {
        _wc.lastModified = lastModified;
        _wc.etag = etag;
        _ls?.saveWebdavConfig(_wc);
      }
    } catch (e) {
      getLogger().error('getModifiedTimeAndEtag failed,$e');
    }
  }
}

enum GetDataStatus { notModified, created, modified, empty }

class GetDataRes {
  final List<Totp>? data;

  final GetDataStatus status;

  GetDataRes({this.data, this.status = GetDataStatus.modified});
}

class WebdavException implements Exception {
  final int httpcode;
  final String errMsg;

  const WebdavException({this.httpcode = -1, this.errMsg = ''});

  @override
  String toString() {
    return 'WebdavException: $httpcode  $errMsg';
  }
}

//自定义client，原来的client返回的Request不能处理二进制数据的上传
class WebDavCustomClient extends WebDavStdClient {
  WebDavCustomClient([super.context]);

  @override
  Future<WebDavStdRequest<P>> openUrl<P extends WebDavRequestParam>({
    required WebDavMethod method,
    required Uri url,
    required P param,
    ResponseBodyDecoderManager? responseBodyDecoders,
    ResponseResultParser<WebDavStdResResultView>? responseResultParser,
  }) => client.openUrl(method.name, url).then((request) {
    return WebDavCustomRequest<P>(
      request: request,
      param: param,
      responseBodyDecoders: responseBodyDecoders,
      responseResultParser: responseResultParser,
    );
  });
}

class WebDavCustomRequest<P extends WebDavRequestParam>
    extends WebDavStdRequest<P> {
  WebDavCustomRequest({
    required super.request,
    required super.param,
    super.responseBodyDecoders,
    super.responseResultParser,
  });

  @override
  Future<WebDavStdResponse<WebDavStdResResultView>> close() {
    param?.beforeAddRequestBody(request);

    if (param is PutRequestParam &&
        (param as PutRequestParam).data is Uint8List) {
      final p = param as PutRequestParam;
      request.add(p.data as Uint8List);
    } else {
      final body = param?.toRequestBody();
      if (body != null) request.write(body);
    }

    return request.close().then(
      (response) => WebDavStdResponse(
        response: response,
        path: request.uri,
        method: method,
        bodyDecoders: responseBodyDecoders ?? kStdDecoderManager,
        resultParser: responseResultParser ?? kStdResponseResultParser,
      ),
    );
  }
}
