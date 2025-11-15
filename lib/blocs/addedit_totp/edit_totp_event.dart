part of 'edit_totp_bloc.dart';

class EditTotpEvent extends Equatable {
  const EditTotpEvent();

  @override
  List<Object> get props => [];
}

final class EditTotpSubmitted extends EditTotpEvent {
  const EditTotpSubmitted(this.totp);
  final Totp totp;
}
