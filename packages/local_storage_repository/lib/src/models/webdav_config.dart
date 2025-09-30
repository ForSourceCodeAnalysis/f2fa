import 'package:json_annotation/json_annotation.dart';

part 'webdav_config.g.dart';

@JsonSerializable()
class WebdavConfig {
  WebdavConfig({
    required this.url,
    required this.username,
    required this.password,
    this.encryptKey,
  });

  final String url;
  final String username;
  final String password;
  @JsonKey(includeIfNull: false)
  final String? encryptKey;

  Map<String, dynamic> toJson() => _$WebdavConfigToJson(this);

  factory WebdavConfig.fromJson(Map<String, dynamic> json) =>
      _$WebdavConfigFromJson(json);
}
