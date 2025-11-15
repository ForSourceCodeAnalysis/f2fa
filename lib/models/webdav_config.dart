class WebdavConfig {
  WebdavConfig({
    required this.url,
    required this.username,
    required this.password,
    required this.encryptKey,
    this.authMethod = AuthMethod.basic,
    this.lastModified,
    this.etag,
  });

  String url;
  String username;
  String password;
  String encryptKey;
  AuthMethod authMethod;
  DateTime? lastModified;
  String? etag;
}

enum AuthMethod { basic, digest }
