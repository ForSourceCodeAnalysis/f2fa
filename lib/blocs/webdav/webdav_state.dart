part of 'webdav_bloc.dart';

enum WebdavStatus { initial, loading, success, failure }

class WebdavState extends Equatable {
  final WebdavStatus status;
  final WebdavException? webdavErr;
  final bool clearForm;
  final String error;

  const WebdavState({
    this.status = WebdavStatus.initial,
    this.webdavErr,
    this.clearForm = false,
    this.error = '',
  });

  WebdavState copyWith({
    WebdavStatus? status,
    WebdavException? webdavErr,
    bool? clearForm,
    String? error,
  }) {
    return WebdavState(
      status: status ?? this.status,
      webdavErr: webdavErr,
      clearForm: clearForm ?? this.clearForm,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, webdavErr, error, clearForm];
}
