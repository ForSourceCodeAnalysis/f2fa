import 'package:equatable/equatable.dart';
import 'package:f2fa/models/webdav_config.dart';
import 'package:f2fa/services/services.dart';
import 'package:f2fa/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'webdav_event.dart';
part 'webdav_state.dart';

class WebdavBloc extends Bloc<WebdavEvent, WebdavState> {
  WebdavBloc({required TotpRepository totprepository})
    : _tr = totprepository,
      super(const WebdavState(status: WebdavStatus.initial)) {
    on<WebdavStatusSubscribe>(_onStatusSubscribe);
    on<WebdavSubmit>(_onSubmit);
    on<WebdavForceSync>(_onForceSync);
    on<WebdavExitSync>(_onExitSync);
  }

  final LocalStorage _localStorage = GetIt.I.get<LocalStorage>();
  final TotpRepository _tr;

  Future<void> _onStatusSubscribe(
    WebdavStatusSubscribe event,
    Emitter<WebdavState> emit,
  ) async {
    await emit.forEach(
      _tr.getWebdavErrors(),
      onData: (webdavErr) =>
          state.copyWith(webdavErr: webdavErr, clearForm: false),
    );
  }

  Future<void> _onSubmit(WebdavSubmit event, Emitter<WebdavState> emit) async {
    emit(state.copyWith(status: WebdavStatus.loading, clearForm: false));

    try {
      final inst = Webdav(
        WebdavConfig(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
        ),
        null,
      );
      final isDir = await inst.checkResType();

      if (!isDir) {
        emit(
          state.copyWith(
            status: WebdavStatus.failure,
            error: getLocaleInstance().webdavNotDir,
          ),
        );
        return;
      }
      // 检查成功后保存配置
      await _localStorage.saveWebdavConfig(
        WebdavConfig(
          url: event.url,
          username: event.username,
          password: event.password,
          encryptKey: event.encryptKey,
        ),
      );
      inst.setLocalStorage(_localStorage);

      // 重新同步数据
      _tr.changeWebdav(inst);
      await _tr.forceSync();
      emit(state.copyWith(status: WebdavStatus.success));
    } catch (e) {
      getLogger().error(e);
      emit(state.copyWith(status: WebdavStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onForceSync(
    WebdavForceSync event,
    Emitter<WebdavState> emit,
  ) async {
    emit(state.copyWith(status: WebdavStatus.loading, clearForm: false));

    try {
      await _tr.forceSync();

      emit(state.copyWith(status: WebdavStatus.success));
    } catch (e) {
      emit(state.copyWith(status: WebdavStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onExitSync(
    WebdavExitSync event,
    Emitter<WebdavState> emit,
  ) async {
    emit(state.copyWith(status: WebdavStatus.loading));

    _tr.changeWebdav(null);
    await _localStorage.saveWebdavConfig(null);
    emit(state.copyWith(status: WebdavStatus.success, clearForm: true));
  }
}
