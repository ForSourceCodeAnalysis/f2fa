part of 'totps_overview_bloc.dart';

enum TotpsOverviewStatus { initial, loading, success, failure }

class TotpsOverviewState extends Equatable {
  const TotpsOverviewState({
    this.status = TotpsOverviewStatus.initial,
    this.webdavErr,
    this.totps = const [],
    this.fakeStatus = 0,
    this.searchQuery = '',
  });

  final List<Totp> totps;
  final TotpsOverviewStatus status;
  final int fakeStatus;
  final WebdavException? webdavErr;
  final String searchQuery;

  TotpsOverviewState copyWith({
    TotpsOverviewStatus? status,
    List<Totp>? totps,
    WebdavException? webdavErr,
    int? fakeStatus,
    String? searchQuery,
    bool clearWebdavErr = false,
  }) {
    return TotpsOverviewState(
      status: status ?? this.status,
      totps: totps ?? this.totps,
      fakeStatus: fakeStatus ?? this.fakeStatus,
      webdavErr: webdavErr ?? (clearWebdavErr ? null : this.webdavErr),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    totps,
    status,
    fakeStatus,
    webdavErr,
    searchQuery,
  ];
}
