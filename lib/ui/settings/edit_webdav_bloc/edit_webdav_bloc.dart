import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:webdav_sync/webdav_sync.dart';

part 'edit_webdav_event.dart';
part 'edit_webdav_state.dart';

class EditWebdavBloc extends Bloc<EditWebdavEvent, EditWebdavState> {
  EditWebdavBloc({
    required LocalStorageRepository localStorage,
    required TotpRepository totprepository,
  }) : _localStorage = localStorage,
       _tr = totprepository,
       super(const EditWebdavState(status: EditWebdavStatus.initial)) {
    on<EditWebdavStatusSubscribe>(_onStatusSubscribe);
    on<EditWebdavSubmit>(_onSubmit);
    on<EditWebdavForceSync>(_onForceSync);
    on<EditWebdavExitSync>(_onExitSync);
  }

  final LocalStorageRepository _localStorage;
  final TotpRepository _tr;

  Future<void> _onStatusSubscribe(
    EditWebdavStatusSubscribe event,
    Emitter<EditWebdavState> emit,
  ) async {
    await emit.forEach(
      _localStorage.getSyncStatus(),
      onData: (webdavStatus) =>
          state.copyWith(webdavStatus: webdavStatus, clearForm: false),
    );
  }

  Future<void> _onSubmit(
    EditWebdavSubmit event,
    Emitter<EditWebdavState> emit,
  ) async {
    emit(state.copyWith(status: EditWebdavStatus.loading, clearForm: false));

    try {
      final inst = await WebdavSync.instance(
        url: event.url,
        username: event.username,
        password: event.password,
        encryptKey: event.encryptKey,
        lsr: _localStorage,
      );
      // 实例化成功后保存配置
      await _localStorage.saveWebdavConfig(
        WebdavConfig(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
        ),
      );
      // 清除之前的错误信息及同步信息
      await _localStorage.clearWebdavErrorInfo();
      await _localStorage.clearWebdavLastModified();
      await _localStorage.clearWebdavEtag();
      // 重新同步数据
      _tr.changeWebdav(inst);
      await _tr.forceSync();
      emit(state.copyWith(status: EditWebdavStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: EditWebdavStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> _onForceSync(
    EditWebdavForceSync event,
    Emitter<EditWebdavState> emit,
  ) async {
    emit(state.copyWith(status: EditWebdavStatus.loading, clearForm: false));

    try {
      _localStorage.clearWebdavLastModified();
      _localStorage.clearWebdavEtag();
      await _tr.forceSync();

      emit(state.copyWith(status: EditWebdavStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: EditWebdavStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> _onExitSync(
    EditWebdavExitSync event,
    Emitter<EditWebdavState> emit,
  ) async {
    emit(state.copyWith(status: EditWebdavStatus.loading));

    _tr.changeWebdav(null);
    await _localStorage.clearWebdavConfig();
    emit(state.copyWith(status: EditWebdavStatus.success, clearForm: true));
  }
}
