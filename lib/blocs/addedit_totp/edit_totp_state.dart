part of 'edit_totp_bloc.dart';

enum EditTotpStatus { initial, loading, success, failure }

class EditTotpState extends Equatable {
  const EditTotpState({
    this.status = EditTotpStatus.initial,
    this.initialTotp,
    this.err,
  });

  final EditTotpStatus status;
  final Totp? initialTotp;
  final Object? err;

  bool get isNewTotp => initialTotp == null;

  @override
  List<Object?> get props => [status, initialTotp];

  EditTotpState copyWith({
    EditTotpStatus? status,
    Totp? initialTotp,
    Object? err,
  }) {
    return EditTotpState(
      status: status ?? this.status,
      err: err ?? this.err,
      initialTotp: initialTotp ?? this.initialTotp,
    );
  }
}
