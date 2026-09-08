import 'package:go_router/go_router.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/navigation/widgets/app_navigation_shell_widget.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/navigation/widgets/app_tab.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/home/home_routes.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/login/login_routes.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/profile/profile_routes.dart';

import 'route_path.dart';

/// Configuración central de navegación de la app — adaptado del sistema de
/// rutas de sam-vision/FleetVision (`GoRouteHelper` + un `xxx_routes.dart`
/// por módulo). Todavía no hay sesión/splash, así que no hay `redirect` ni
/// `refreshListenable`: se agregan acá el día que exista ese flujo, igual
/// criterio que usa sam-vision con su `AuthEventBus`.
mixin Routes {
  final GoRouter _router = GoRouter(
    initialLocation: RoutePath.inicial,
    routes: [
      LoginRoutes.login,

      // Ramas con bottom nav persistente (ver AppNavigationShell) — una
      // StatefulShellBranch por cada AppTab, en el mismo orden de
      // `AppTab.values`. Construida iterando el enum (no una lista de
      // GoRoute escrita a mano) para que agregar una pestaña nueva sin
      // cablear su ruta en `_routeFor` sea un error de compilación, no un
      // bug silencioso de "la barra y las ramas quedaron desincronizadas".
      // Login queda afuera a propósito: no es parte de la navegación
      // principal, igual criterio que sam-vision.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppNavigationShell(navigationShell: navigationShell),
        branches: [
          for (final tab in AppTab.values)
            StatefulShellBranch(routes: [_routeFor(tab)]),
        ],
      ),
    ],
  );

  GoRouter get router => _router;
}

/// Único lugar donde se traduce cada [AppTab] a su [GoRoute] real. Un
/// `switch` exhaustivo sobre un enum: si se agrega un valor nuevo a
/// [AppTab] y no se cablea acá, el proyecto directamente no compila.
GoRoute _routeFor(AppTab tab) => switch (tab) {
      AppTab.home => HomeRoutes.home,
      AppTab.profile => ProfileRoutes.profile,
    };
