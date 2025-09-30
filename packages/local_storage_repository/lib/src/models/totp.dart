import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'totp.g.dart';

@immutable
@JsonSerializable()
class Totp extends Equatable {
  Totp({
    required this.issuer,
    required this.account,
    required this.secret,
    String type = 'totp',
    String algorithm = 'sha1',
    this.digits = 6,
    this.period = 30,
    this.code = '',
    this.remaining = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.deleteStatus = 0,
  }) : type = type.toLowerCase(),
       algorithm = algorithm.toLowerCase();

  final String type;
  final String issuer;
  final String account;
  final String secret;
  final String algorithm;
  final int digits;
  final int period;
  final int createdAt;
  final int updatedAt;
  final int deleteStatus; //0 未删除，1 删除，2 彻底删除

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String code;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int remaining;

  String get id => '$issuer:$account';

  factory Totp.fromJson(Map<String, dynamic> json) => _$TotpFromJson(json);

  Map<String, dynamic> toJson() => _$TotpToJson(this);

  static Totp? parseFromUrl(String url) {
    final uri = Uri.parse(url);

    if (uri.scheme == 'otpauth' && uri.host == "totp") {
      final issuer = uri.queryParameters['issuer'] ?? "";
      var issueraccount = uri.pathSegments.last.split(":");
      final account = issueraccount.length > 1
          ? issueraccount[1]
          : issueraccount[0];
      final secret = uri.queryParameters['secret'] ?? "";

      if (secret.isNotEmpty) {
        return Totp(issuer: issuer, account: account, secret: secret);
      }
    }
    return null;
  }

  Totp copyWith({
    String? type,
    String? issuer,
    String? account,
    String? secret,
    String? algorithm,
    int? digits,
    int? period,
    String? code,
    int? remaining,
    // int? order,
    int? createdAt,
    int? updatedAt,

    int? deleteStatus,
  }) {
    return Totp(
      type: type ?? this.type,
      issuer: issuer ?? this.issuer,
      account: account ?? this.account,
      secret: secret ?? this.secret,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      code: code ?? this.code,
      remaining: remaining ?? this.remaining,
      // order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleteStatus: deleteStatus ?? this.deleteStatus,
    );
  }

  @override
  List<Object?> get props => [
    issuer,
    account,
    secret,
    type,
    algorithm,
    digits,
    period,
    id,
    code,
    remaining,
    createdAt,
    updatedAt,
    deleteStatus,
  ];
}
