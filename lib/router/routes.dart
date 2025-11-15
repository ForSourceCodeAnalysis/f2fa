import 'package:go_router/go_router.dart';
import 'package:f2fa/router/home_route.dart' as home;
import 'package:f2fa/router/settings_route.dart' as settings;

final GoRouter approuter = GoRouter(
  initialLocation: const home.HomeRoute().location,
  routes: <RouteBase>[...home.$appRoutes, ...settings.$appRoutes],
);
