part of 'edit_webdav_bloc.dart';

abstract class EditWebdavEvent extends Equatable {
  const EditWebdavEvent();

  @override
  List<Object?> get props => [];
}

class EditWebdavSubmit extends EditWebdavEvent {
  const EditWebdavSubmit({
    required this.url,
    required this.username,
    required this.password,
    this.encryptKey,
    this.overwrite,
  });
  final String url;
  final String username;
  final String password;
  final String? encryptKey;
  final bool? overwrite;

  @override
  List<Object?> get props => [url, username, password, encryptKey, overwrite];
}
