import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';

part 'edit_webdav_event.dart';
part 'edit_webdav_state.dart';

class EditWebdavBloc extends Bloc<EditWebdavEvent, EditWebdavState> {
  EditWebdavBloc({
    required TotpRepository totpRepository,
    required LocalStorageRepository localStorage,
    WebdavConfig? initialWebdav,
  })  : _totpRepository = totpRepository,
        _localStorage = localStorage,
        super(EditWebdavState(
          status: EditWebdavStatus.initial,
          initialWebdav: initialWebdav,
          url: initialWebdav?.url ?? '',
          username: initialWebdav?.username ?? '',
          password: initialWebdav?.password ?? '',
          encryptKey: initialWebdav?.encryptKey ?? '',
        )) {
    on<EditWebdavSubmit>(_onSubmit);
  }
  final TotpRepository _totpRepository;
  final LocalStorageRepository _localStorage;

  Future<void> _onSubmit(
    EditWebdavSubmit event,
    Emitter<EditWebdavState> emit,
  ) async {
    emit(state.copyWith(status: EditWebdavStatus.loading));

    try {
      final totpApi = await WebdavTotpApi.instance(
        url: event.url,
        username: event.username,
        password: event.password,
        encryptKey: event.encryptKey,
        overwrite: event.overwrite,
      );

      _totpRepository.changeApi(totpApi);
      _localStorage.saveWebdavConfig(
        WebdavConfig(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
        ),
      );

      emit(state.copyWith(status: EditWebdavStatus.success));
    } catch (e) {
      final WebDAVErrorType err;
      if (e is WebDAVException) {
        err = e.type;
      } else {
        err = WebDAVErrorType.unknownError;
      }
      emit(state.copyWith(
        url: event.url,
        username: event.username,
        password: event.password,
        encryptKey: event.encryptKey,
        status: EditWebdavStatus.failure,
        error: err,
      ));
    }
  }
}
