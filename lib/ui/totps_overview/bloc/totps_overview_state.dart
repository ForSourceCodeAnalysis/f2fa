part of 'totps_overview_bloc.dart';

enum TotpsOverviewStatus { initial, loading, success, failure }

class TotpsOverviewState extends Equatable {
  const TotpsOverviewState({
    this.status = TotpsOverviewStatus.initial,
    this.totps = const [],
  });

  final List<Totp> totps;
  final TotpsOverviewStatus status;

  TotpsOverviewState copyWith({
    TotpsOverviewStatus? status,
    List<Totp>? totps,
  }) {
    return TotpsOverviewState(
      status: status ?? this.status,
      totps: totps ?? this.totps,
    );
  }

  @override
  List<Object> get props => [totps, status];
}
