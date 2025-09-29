part of 'edit_totp_bloc.dart';

enum EditTotpStatus { initial, loading, success, failure }

class EditTotpState extends Equatable {
  const EditTotpState({this.status = EditTotpStatus.initial, this.initialTotp});

  final EditTotpStatus status;
  final Totp? initialTotp;
  // final String issuer;
  // final String account;
  // final String secret;
  // final int period;
  // final String algorithm;
  // final int digits;
  // final String type;

  bool get isNewTotp => initialTotp == null;

  @override
  List<Object?> get props => [
    status,
    initialTotp,
    // issuer,
    // account,
    // secret,
    // period,
    // algorithm,
    // digits,
  ];

  EditTotpState copyWith({
    EditTotpStatus? status,
    Totp? initialTotp,
    // String? issuer,
    // String? account,
    // String? secret,
    // int? period,
    // String? algorithm,
    // int? digits,
  }) {
    return EditTotpState(
      status: status ?? this.status,
      initialTotp: initialTotp ?? this.initialTotp,
      // issuer: issuer ?? this.issuer,
      // account: account ?? this.account,
      // secret: secret ?? this.secret,
      // period: period ?? this.period,
      // algorithm: algorithm ?? this.algorithm,
      // digits: digits ?? this.digits,
    );
  }
}
