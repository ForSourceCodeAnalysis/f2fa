class WebDAVException implements Exception {
  const WebDAVException(this.code, {this.msg = ''});
  final int code;
  final String msg;

  @override
  String toString() {
    return 'WebDAVException{code: $code, msg: $msg}';
  }
}
