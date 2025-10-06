part of 'totps_overview_bloc.dart';

enum TotpsOverviewStatus { initial, loading, success, failure }

class TotpsOverviewState extends Equatable {
  const TotpsOverviewState({
    this.status = TotpsOverviewStatus.initial,
    this.syncStatus = const WebdavStatus(),
    this.totps = const [],
    this.fakeStatus = 0,
    this.searchQuery = '',
  });

  final List<Totp> totps;
  final TotpsOverviewStatus status;
  final int fakeStatus;
  final WebdavStatus syncStatus;
  final String searchQuery;

  TotpsOverviewState copyWith({
    TotpsOverviewStatus? status,
    List<Totp>? totps,
    WebdavStatus? syncStatus,
    int? fakeStatus,
    String? searchQuery,
  }) {
    return TotpsOverviewState(
      status: status ?? this.status,
      totps: totps ?? this.totps,
      fakeStatus: fakeStatus ?? this.fakeStatus,
      syncStatus: syncStatus ?? this.syncStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
    totps,
    status,
    fakeStatus,
    syncStatus,
    searchQuery,
  ];
}
