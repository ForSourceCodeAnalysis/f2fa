class WebDAVException implements Exception {
  const WebDAVException(this.type);
  final WebDAVErrorType type;
}

enum WebDAVErrorType { unknownError, connectError, parseError, overwriteError }

extension WebDAVErrorTypeExtension on WebDAVErrorType {
  String get name {
    switch (this) {
      case WebDAVErrorType.unknownError:
        return 'UnknownError';
      case WebDAVErrorType.connectError:
        return 'ConnectError';
      case WebDAVErrorType.parseError:
        return 'ParseError';
      case WebDAVErrorType.overwriteError:
        return 'OverwriteError';
    }
  }
}
