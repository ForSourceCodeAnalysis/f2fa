part of 'edit_totp_bloc.dart';

class EditTotpEvent extends Equatable {
  const EditTotpEvent();

  @override
  List<Object> get props => [];
}

final class EditTotpIssuerChanged extends EditTotpEvent {
  const EditTotpIssuerChanged(this.issuer);

  final String issuer;

  @override
  List<Object> get props => [issuer];
}

final class EditTotpAccountChanged extends EditTotpEvent {
  const EditTotpAccountChanged(this.account);

  final String account;

  @override
  List<Object> get props => [account];
}

final class EditTotpTypeChanged extends EditTotpEvent {
  const EditTotpTypeChanged(this.type);

  final String type;

  @override
  List<Object> get props => [type];
}

final class EditTotpSecretChanged extends EditTotpEvent {
  const EditTotpSecretChanged(this.secret);

  final String secret;

  @override
  List<Object> get props => [secret];
}

final class EditTotpPeriodChanged extends EditTotpEvent {
  const EditTotpPeriodChanged(this.period);

  final int period;

  @override
  List<Object> get props => [period];
}

final class EditTotpDigitsChanged extends EditTotpEvent {
  const EditTotpDigitsChanged(this.digits);

  final int digits;

  @override
  List<Object> get props => [digits];
}

final class EditTotpAlgorithmChanged extends EditTotpEvent {
  const EditTotpAlgorithmChanged(this.algorithm);

  final String algorithm;

  @override
  List<Object> get props => [algorithm];
}

final class EditTotpSubmitted extends EditTotpEvent {
  const EditTotpSubmitted();
}
