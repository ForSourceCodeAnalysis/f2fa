import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'totps_overview_event.dart';
part 'totps_overview_state.dart';

class TotpsOverviewBloc extends Bloc<TotpsOverviewEvent, TotpsOverviewState> {
  TotpsOverviewBloc({required TotpRepository totpRepository})
    : _totpRepository = totpRepository,
      super(const TotpsOverviewState()) {
    on<TotpsOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<TotpsOverviewWebdavStatusSubscribe>(_onWebdavStatusSubscribe);
    on<TotpsOverviewTotpUpdated>(_onTotpUpdated);
    on<TotpsOverviewTotpDeleted>(_onTotpDeleted);
    on<TotpsOverviewTotpAdded>(_onTotpAdded);
    on<TotpsOverviewReordered>(_onReordered);
    on<TotpsOverviewSearchQueryChanged>(
      _mapTotpsOverviewSearchQueryChangedToState,
    );
  }

  final TotpRepository _totpRepository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> _onSubscriptionRequested(
    TotpsOverviewSubscriptionRequested event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    await emit.forEach<List<Totp>>(
      _totpRepository.getTotps(),
      onData: (totps) {
        return state.copyWith(
          totps: totps,
          status: TotpsOverviewStatus.success,
          fakeStatus: state.fakeStatus + 1,
        );
      },
      onError: null,
    );
  }

  Future<void> _onTotpUpdated(
    TotpsOverviewTotpUpdated event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    if (event.onOff) {
      if (_subscription != null) {
        return;
      }
      _subscription = Stream.periodic(
        const Duration(seconds: 1),
      ).listen((_) => _totpRepository.refreshCode());
    } else {
      await _subscription?.cancel();
      _subscription = null;
    }
  }

  Future<void> _onWebdavStatusSubscribe(
    TotpsOverviewWebdavStatusSubscribe event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    await emit.forEach<WebdavException?>(
      _totpRepository.getWebdavErrors(),
      onData: (webdavErr) {
        return state.copyWith(
          webdavErr: webdavErr,
          fakeStatus: state.fakeStatus + 1,
          clearWebdavErr: true,
        );
      },
      onError: null,
    );
  }

  Future<void> _onTotpDeleted(
    TotpsOverviewTotpDeleted event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    await _totpRepository.deleteTotp(event.totp.id);
  }

  Future<void> _onTotpAdded(
    TotpsOverviewTotpAdded event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    await _totpRepository.saveTotp(event.totp);
  }

  Future<void> _onReordered(
    TotpsOverviewReordered event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    if (event.newIndex == event.oldIndex) return;

    final totp = state.totps.removeAt(event.oldIndex);
    state.totps.insert(event.newIndex, totp);

    await _totpRepository.reorderTotps(state.totps);
  }

  Future<void> _mapTotpsOverviewSearchQueryChangedToState(
    TotpsOverviewSearchQueryChanged event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
  }
}
