part of 'totps_overview_bloc.dart';

sealed class TotpsOverviewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TotpsOverviewSubscriptionRequested extends TotpsOverviewEvent {}

class TotpsOverviewTotpUpdated extends TotpsOverviewEvent {
  final bool onOff;
  TotpsOverviewTotpUpdated(this.onOff);

  @override
  List<Object?> get props => [onOff];
}

class TotpsOverviewTotpDeleted extends TotpsOverviewEvent {
  final Totp totp;
  TotpsOverviewTotpDeleted(this.totp);

  @override
  List<Object?> get props => [totp];
}

class TotpsOverviewTotpAdded extends TotpsOverviewEvent {
  final Totp totp;
  TotpsOverviewTotpAdded(this.totp);

  @override
  List<Object?> get props => [totp];
}

class TotpsOverviewReordered extends TotpsOverviewEvent {
  final int oldIndex;
  final int newIndex;

  TotpsOverviewReordered({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
