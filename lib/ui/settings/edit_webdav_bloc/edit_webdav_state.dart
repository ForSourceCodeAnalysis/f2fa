part of 'edit_webdav_bloc.dart';

enum EditWebdavStatus { initial, loading, success, failure }

extension EditWebdavStatusX on EditWebdavStatus {
  bool get isLoadingOrSuccess =>
      [EditWebdavStatus.loading, EditWebdavStatus.success].contains(this);
}

class EditWebdavState extends Equatable {
  final EditWebdavStatus status;
  final WebdavConfig? initialWebdav;
  final String url;
  final String username;
  final String password;
  final String encryptKey;
  final String? error;

  const EditWebdavState({
    this.status = EditWebdavStatus.initial,
    this.initialWebdav,
    this.error,
    required this.url,
    required this.username,
    required this.password,
    required this.encryptKey,
  });

  EditWebdavState copyWith({
    EditWebdavStatus? status,
    WebdavConfig? initialWebdav,
    String? url,
    String? username,
    String? password,
    String? encryptKey,
    String? error,
  }) {
    return EditWebdavState(
      status: status ?? this.status,
      initialWebdav: initialWebdav ?? this.initialWebdav,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      encryptKey: encryptKey ?? this.encryptKey,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialWebdav,
    url,
    username,
    password,
    encryptKey,
    error,
  ];
}
