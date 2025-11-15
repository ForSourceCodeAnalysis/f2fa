import 'package:equatable/equatable.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'edit_totp_event.dart';
part 'edit_totp_state.dart';

class EditTotpBloc extends Bloc<EditTotpEvent, EditTotpState> {
  EditTotpBloc({required TotpRepository totpRepository, Totp? initialTotp})
    : _totpRepository = totpRepository,
      super(EditTotpState(initialTotp: initialTotp)) {
    on<EditTotpSubmitted>(_onSubmitted);
  }
  final TotpRepository _totpRepository;

  Future<void> _onSubmitted(
    EditTotpSubmitted event,
    Emitter<EditTotpState> emit,
  ) async {
    emit(state.copyWith(status: EditTotpStatus.loading));

    final totp = event.totp;
    try {
      await _totpRepository.saveTotp(totp, oldTotp: state.initialTotp);
    } catch (e) {
      emit(state.copyWith(status: EditTotpStatus.failure, err: e));
      return;
    }

    emit(state.copyWith(status: EditTotpStatus.success));
  }
}
