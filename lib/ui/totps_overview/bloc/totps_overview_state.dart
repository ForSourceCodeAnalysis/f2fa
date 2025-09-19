part of 'totps_overview_bloc.dart';

enum TotpsOverviewStatus { initial, loading, success, failure }

class TotpsOverviewState extends Equatable {
  const TotpsOverviewState({
    this.status = TotpsOverviewStatus.initial,
    this.totps = const [],
    this.fakeStatus = 0,
  });

  final List<Totp> totps;
  final TotpsOverviewStatus status;
  final int fakeStatus;

  TotpsOverviewState copyWith({
    TotpsOverviewStatus? status,
    List<Totp>? totps,
    int? fakeStatus,
  }) {
    return TotpsOverviewState(
      status: status ?? this.status,
      totps: totps ?? this.totps,
      fakeStatus: fakeStatus ?? this.fakeStatus,
    );
  }

  @override
  List<Object> get props => [totps, status, fakeStatus];
}
