import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';

part 'edit_totp_event.dart';
part 'edit_totp_state.dart';

class EditTodoBloc extends Bloc<EditTotpEvent, EditTotpState> {
  EditTodoBloc({required TotpRepository totpRepository, Totp? initialTotp})
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
    print('object id: ${totp.id}, initial id: ${state.initialTotp?.id}');

    await _totpRepository.saveTotp(totp, oldTotp: state.initialTotp);

    emit(state.copyWith(status: EditTotpStatus.success));
  }
}
