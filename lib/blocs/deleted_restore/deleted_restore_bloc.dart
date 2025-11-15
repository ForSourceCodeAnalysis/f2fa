import 'package:equatable/equatable.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'deleted_restore_event.dart';
part 'deleted_restore_state.dart';

class DeletedRestoreBloc
    extends Bloc<DeletedRestoreEvent, DeletedRestoreState> {
  DeletedRestoreBloc(TotpRepository tr)
    : _totpRepository = tr,
      super(const DeletedRestoreState()) {
    on<DeletedRestoreInit>(_onInit);
    on<DeletedRestoreRestore>(_onRestore);
    on<DeletedRestoreDeletePermanently>(_onDeletePermanently);
    on<DeletedRestoreClearAll>(_onClearAll);
  }
  final TotpRepository _totpRepository;

  Future<void> _onInit(
    DeletedRestoreInit event,
    Emitter<DeletedRestoreState> emit,
  ) async {
    final deletedTotps = _totpRepository.getDeletedTotps();
    emit(
      state.copyWith(status: DeletedRestoreStatus.success, totps: deletedTotps),
    );
  }

  Future<void> _onRestore(
    DeletedRestoreRestore event,
    Emitter<DeletedRestoreState> emit,
  ) async {
    emit(state.copyWith(status: DeletedRestoreStatus.loading));
    await _totpRepository.restoreTotp(event.id);
    final deletedTotps = _totpRepository.getDeletedTotps();
    emit(
      state.copyWith(status: DeletedRestoreStatus.success, totps: deletedTotps),
    );
  }

  Future<void> _onDeletePermanently(
    DeletedRestoreDeletePermanently event,
    Emitter<DeletedRestoreState> emit,
  ) async {
    emit(state.copyWith(status: DeletedRestoreStatus.loading));
    await _totpRepository.deletePermanently(event.id);
    final deletedTotps = _totpRepository.getDeletedTotps();
    emit(
      state.copyWith(status: DeletedRestoreStatus.success, totps: deletedTotps),
    );
  }

  Future<void> _onClearAll(
    DeletedRestoreClearAll event,
    Emitter<DeletedRestoreState> emit,
  ) async {
    emit(state.copyWith(status: DeletedRestoreStatus.loading));
    await _totpRepository.clearAllDeletedTotps();
    // final deletedTotps = _totpRepository.getDeletedTotps();
    emit(state.copyWith(status: DeletedRestoreStatus.success, totps: []));
  }
}
