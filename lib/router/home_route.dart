import 'package:f2fa/models/models.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'home_route.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<AddEditTotpRoute>(path: 'add_edit_totp'),
    TypedGoRoute<ScannerRoute>(path: 'scanner'),
  ],
)
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

@immutable
class AddEditTotpRoute extends GoRouteData with $AddEditTotpRoute {
  const AddEditTotpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EditTotpPage(initialTotp: state.extra as Totp?);
  }
}

@immutable
class ScannerRoute extends GoRouteData with $ScannerRoute {
  const ScannerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ScannerPage();
  }
}
