import 'package:go_router/go_router.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/home/home_routes.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/login/login_routes.dart';

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
      HomeRoutes.home,
    ],
  );

  GoRouter get router => _router;
}
