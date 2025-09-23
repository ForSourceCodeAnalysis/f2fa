import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:webdav_sync/webdav_sync.dart';

part 'edit_webdav_event.dart';
part 'edit_webdav_state.dart';

class EditWebdavBloc extends Bloc<EditWebdavEvent, EditWebdavState> {
  EditWebdavBloc({
    required LocalStorageRepository localStorage,
    WebdavConfig? initialWebdav,
  }) : _localStorage = localStorage,
       super(
         EditWebdavState(
           status: EditWebdavStatus.initial,
           initialWebdav: initialWebdav,
           url: initialWebdav?.url ?? '',
           username: initialWebdav?.username ?? '',
           password: initialWebdav?.password ?? '',
           encryptKey: initialWebdav?.encryptKey ?? '',
         ),
       ) {
    on<EditWebdavSubmit>(_onSubmit);
  }

  final LocalStorageRepository _localStorage;

  Future<void> _onSubmit(
    EditWebdavSubmit event,
    Emitter<EditWebdavState> emit,
  ) async {
    emit(state.copyWith(status: EditWebdavStatus.loading));

    try {
      await WebdavSync.instance(
        url: event.url,
        username: event.username,
        password: event.password,
        encryptKey: event.encryptKey,
        lsr: _localStorage,
      );
      await _localStorage.saveWebdavConfig(
        WebdavConfig(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
        ),
      );
      emit(state.copyWith(status: EditWebdavStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
          status: EditWebdavStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
