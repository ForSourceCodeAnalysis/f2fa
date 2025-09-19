import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totp_repository/totp_repository.dart';

part 'totps_overview_event.dart';
part 'totps_overview_state.dart';

class TotpsOverviewBloc extends Bloc<TotpsOverviewEvent, TotpsOverviewState> {
  TotpsOverviewBloc({required TotpRepository totpRepository})
    : _totpRepository = totpRepository,
      super(const TotpsOverviewState()) {
    on<TotpsOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<TotpsOverviewTotpUpdated>(_onTotpUpdated);
    on<TotpsOverviewTotpDeleted>(_onTotpDeleted);
    on<TotpsOverviewTotpAdded>(_onTotpAdded);
    on<TotpsOverviewReordered>(_onReordered);
  }

  final TotpRepository _totpRepository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> _onSubscriptionRequested(
    TotpsOverviewSubscriptionRequested event,
    Emitter<TotpsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: TotpsOverviewStatus.loading));

    await emit.forEach<List<Totp>>(
      _totpRepository.getTotps(),
      onData: (totps) {
        return state.copyWith(
          totps: totps,
          status: TotpsOverviewStatus.success,
          fakeStatus: state.fakeStatus + 1,
        );
      },
      onError: (_, __) => state.copyWith(status: TotpsOverviewStatus.failure),
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
      ).listen((_) => _totpRepository.tickerUpdateCode());
    } else {
      if (_subscription == null) {
        return;
      }
      await _subscription?.cancel();
      _subscription = null;
    }
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

    try {
      await _totpRepository.reorderTotps(state.totps);
    } catch (e) {
      emit(state.copyWith(status: TotpsOverviewStatus.failure));
      return;
    }
  }
}
