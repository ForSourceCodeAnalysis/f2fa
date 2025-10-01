part of 'edit_webdav_bloc.dart';

enum EditWebdavStatus { initial, loading, success, failure }

class EditWebdavState extends Equatable {
  final EditWebdavStatus status;
  final WebdavStatus webdavStatus;
  final bool clearForm;
  final String error;

  const EditWebdavState({
    this.status = EditWebdavStatus.initial,
    this.webdavStatus = const WebdavStatus(),
    this.clearForm = false,
    this.error = '',
  });

  EditWebdavState copyWith({
    EditWebdavStatus? status,
    WebdavStatus? webdavStatus,
    bool? clearForm,
    String? error,
  }) {
    return EditWebdavState(
      status: status ?? this.status,
      webdavStatus: webdavStatus ?? this.webdavStatus,
      clearForm: clearForm ?? this.clearForm,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, webdavStatus, error, clearForm];
}
