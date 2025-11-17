import 'package:f2fa/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'settings_route.g.dart';

@TypedGoRoute<SettingsRoute>(
  path: '/settings',
  routes: [
    TypedGoRoute<WebdavRoute>(path: 'webdav'),
    TypedGoRoute<ThemeRoute>(path: 'theme'),
    TypedGoRoute<LanguageRoute>(path: 'language'),
    TypedGoRoute<ImportExportRoute>(path: 'import-export'),
    TypedGoRoute<RecycleBinRoute>(path: 'recycle-bin'),
    TypedGoRoute<LogRoute>(path: 'log'),

    TypedGoRoute<FeedbackRoute>(path: 'feedback'),
    TypedGoRoute<AboutRoute>(path: 'about'),
  ],
)
@immutable
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }
}

@immutable
class WebdavRoute extends GoRouteData with $WebdavRoute {
  const WebdavRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebdavPage();
  }
}

@immutable
class ThemeRoute extends GoRouteData with $ThemeRoute {
  const ThemeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ThemePage();
  }
}

@immutable
class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LanguagePage();
  }
}

@immutable
class ImportExportRoute extends GoRouteData with $ImportExportRoute {
  const ImportExportRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ImportExportPage();
  }
}

@immutable
class RecycleBinRoute extends GoRouteData with $RecycleBinRoute {
  const RecycleBinRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RecycleBinPage();
  }
}

@immutable
class LogRoute extends GoRouteData with $LogRoute {
  const LogRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LogPage();
  }
}

@immutable
class FeedbackRoute extends GoRouteData with $FeedbackRoute {
  const FeedbackRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeedbackPage();
  }
}

@immutable
class AboutRoute extends GoRouteData with $AboutRoute {
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AboutPage();
  }
}
