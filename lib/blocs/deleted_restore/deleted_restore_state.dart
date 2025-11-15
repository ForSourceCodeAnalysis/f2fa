part of 'deleted_restore_bloc.dart';

enum DeletedRestoreStatus { initial, loading, success, failure }

class DeletedRestoreState extends Equatable {
  const DeletedRestoreState({
    this.status = DeletedRestoreStatus.initial,
    this.totps = const [],
    this.error,
  });
  final DeletedRestoreStatus status;
  final List<Totp> totps;
  final String? error;

  @override
  List<Object?> get props => [status, totps, error];

  DeletedRestoreState copyWith({
    DeletedRestoreStatus? status,
    List<Totp>? totps,
    String? error,
  }) {
    return DeletedRestoreState(
      status: status ?? this.status,
      totps: totps ?? this.totps,
      error: error ?? this.error,
    );
  }
}
