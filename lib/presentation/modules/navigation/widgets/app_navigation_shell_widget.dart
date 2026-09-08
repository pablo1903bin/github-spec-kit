import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar_widget.dart';
import 'app_tab.dart';

/// Envuelve las ramas de `StatefulShellRoute.indexedStack` (ver
/// `routes.dart`) con el bottom nav — adaptado de sam-vision/FleetVision
/// (`AppNavigationShell`), recortado a un único mecanismo: acá no existe
/// todavía la decisión Drawer/Sidebar por `ScreenClass` (no hay
/// infraestructura responsiva en este proyecto) ni la variante Desktop —
/// solo el caso `phone`/`tablet` con bottom nav.
///
/// `navigationShell` es el `StatefulNavigationShell` que GoRouter arma solo:
/// es la ÚNICA fuente de verdad de qué pestaña está activa (`currentIndex`)
/// y de cómo cambiar de pestaña (`goBranch`) — a diferencia de sam-vision,
/// acá no hace falta un `WorkspaceController` aparte para eso (ver doc de
/// [AppTab]). El orden de `AppTab.values` debe coincidir con el orden de
/// los `StatefulShellBranch` en `routes.dart` — ver doc de [AppTab] para el
/// mecanismo que lo garantiza.
class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body pinta hasta el borde inferior real de la pantalla (no se
      // encoge para dejarle espacio a `bottomNavigationBar`) — sin esto no
      // habría contenido real detrás de la cápsula de vidrio y el blur de
      // `GlassContainer` (ver `AppBottomNavBar`) desenfocaría el fondo del
      // Scaffold en vez del contenido de cada pestaña.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        tabs: AppTab.values,
        currentIndex: navigationShell.currentIndex,
        onSeleccionar: (index) => navigationShell.goBranch(
          index,
          // Volver a tocar la pestaña ya activa vuelve a su primera pantalla
          // (mismo criterio que Google/Instagram) en vez de apilar más allá
          // de la raíz de esa rama.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
