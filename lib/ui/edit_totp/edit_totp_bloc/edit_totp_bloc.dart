import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totp_repository/totp_repository.dart';

part 'edit_totp_event.dart';
part 'edit_totp_state.dart';

class EditTodoBloc extends Bloc<EditTotpEvent, EditTotpState> {
  EditTodoBloc({
    required TotpRepository totpRepository,
    Totp? initialTotp,
  })  : _totpRepository = totpRepository,
        super(EditTotpState(
          initialTotp: initialTotp,
          issuer: initialTotp?.issuer ?? '',
          account: initialTotp?.account ?? '',
          secret: initialTotp?.secret ?? '',
        )) {
    on<EditTotpAccountChanged>(_onAccountChanged);
    on<EditTotpIssuerChanged>(_onIssuerChanged);
    on<EditTotpSecretChanged>(_onSecretChanged);
    on<EditTotpPeriodChanged>(_onPeriodChanged);
    on<EditTotpDigitsChanged>(_onDigitsChanged);
    on<EditTotpAlgorithmChanged>(_onAlgorithmChanged);
    on<EditTotpSubmitted>(_onSubmitted);
  }
  final TotpRepository _totpRepository;

  void _onAccountChanged(
    EditTotpAccountChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(account: event.account));
  }

  void _onIssuerChanged(
    EditTotpIssuerChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(issuer: event.issuer));
  }

  void _onSecretChanged(
    EditTotpSecretChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(secret: event.secret));
  }

  void _onPeriodChanged(
    EditTotpPeriodChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(period: event.period));
  }

  void _onDigitsChanged(
    EditTotpDigitsChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(digits: event.digits));
  }

  void _onAlgorithmChanged(
    EditTotpAlgorithmChanged event,
    Emitter<EditTotpState> emit,
  ) {
    emit(state.copyWith(algorithm: event.algorithm));
  }

  Future<void> _onSubmitted(
    EditTotpSubmitted event,
    Emitter<EditTotpState> emit,
  ) async {
    emit(state.copyWith(status: EditTotpStatus.loading));

    final totp = Totp(
      type: state.type,
      issuer: state.issuer,
      account: state.account,
      secret: state.secret,
      period: state.period,
      digits: state.digits,
      algorithm: state.algorithm,
    );

    try {
      await _totpRepository.saveTotp(totp);

      emit(state.copyWith(status: EditTotpStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditTotpStatus.failure));
    }
  }
}
