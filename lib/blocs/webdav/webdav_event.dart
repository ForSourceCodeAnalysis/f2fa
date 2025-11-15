part of 'webdav_bloc.dart';

abstract class WebdavEvent extends Equatable {
  const WebdavEvent();

  @override
  List<Object?> get props => [];
}

class WebdavStatusSubscribe extends WebdavEvent {
  const WebdavStatusSubscribe();
}

class WebdavSubmit extends WebdavEvent {
  const WebdavSubmit({
    required this.url,
    required this.username,
    required this.password,
    required this.encryptKey,
    this.overwrite,
  });
  final String url;
  final String username;
  final String password;
  final String encryptKey;
  final bool? overwrite;

  @override
  List<Object?> get props => [url, username, password, encryptKey, overwrite];
}

class WebdavForceSync extends WebdavEvent {}

class WebdavExitSync extends WebdavEvent {}
