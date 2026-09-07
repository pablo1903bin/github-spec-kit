import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/global/i18n_provider.dart';


class GoRouteHelper {
  /*goRoute Método: Este método se utiliza para definir una ruta que puede estar asociada con un controlador
   (ChangeNotifier). Si se pasa un controlador, el widget de la ruta se envuelve en un ChangeNotifierProvider,
    lo que permite que el widget observe y reaccione a los cambios en el estado. */
  // Método goRoute
  static GoRoute goRoute<T extends ChangeNotifier>(
      String route, Widget Function() screen,
      {T Function()? controller}) {
    return GoRoute(
      name: toName(route),
      // Define el path de la ruta
      path: route,
      // Define el builder de la ruta que construirá el widget asociado a esta ruta
      builder: controller == null
          // Si no hay controlador, simplemente crea el widget
          ? (_, __) => screen()
          // Si hay un controlador, envuelve el widget con el controlador
          : (context, state) {
              return routeController(screen, controller);
            },
    );
  }

  // Método que envuelve el widget con un ChangeNotifierProvider
  static ChangeNotifierProvider<T> routeController<T extends ChangeNotifier>(
      Widget Function() crear, T Function() controller) {
    return ChangeNotifierProvider<T>(
      // Crea una instancia del controlador
      create: (context) => controller(),
      // Construye el widget hijo
      child: crear(),
    );
  }

  static GoRoute goRouteMulti(
    String route,
    Widget Function() crear,
    List<ChangeNotifierProvider> controllers, {
    Duration transitionDuration = const Duration(milliseconds: 500),
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  }) {
    return GoRoute(
      name: toName(route),
      path: route,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: routeControllers(crear, controllers),
          transitionDuration: transitionDuration,
          transitionsBuilder: transitionsBuilder ??
              (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );

                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
        );
      },
    );
  }

  static MultiProvider routeControllers(
      Widget Function() crear, List<ChangeNotifierProvider> controllers) {
    return MultiProvider(
        providers: controllers,
        child: Consumer<I18nProvider>(builder: (___, _, __) => crear()));
  }

  static ChangeNotifierProvider c<T extends ChangeNotifier>(
      T Function() crear) {
    return ChangeNotifierProvider<T>(create: (context) => crear());
  }

  // Método que convierte una ruta en un nombre. `GoRoute` exige un nombre no
  // vacío — la ruta raíz ("/") se queda sin caracteres tras quitar las
  // barras, así que ese caso puntual necesita un nombre explícito.
  static String toName(String v) {
    if (v == "/") return "root";
    return v.replaceAll("/", "");
  }

  // Ruta simple sin Provider, pero con transición animada opcional
  static GoRoute goRouteSimple(
    String route,
    Widget Function() crear, {
    Duration transitionDuration = const Duration(milliseconds: 500),
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  }) {
    return GoRoute(
      name: toName(route),
      path: route,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: crear(),
          transitionDuration: transitionDuration,
          transitionsBuilder: transitionsBuilder ??
              (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );

                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
        );
      },
    );
  }

  static GoRoute goRouteMultiState(
    String route,
    Widget Function(GoRouterState state) crear,
    List<ChangeNotifierProvider> Function(GoRouterState state, BuildContext context) creaControllers, {
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) {
    return GoRoute(
      name: toName(route),
      path: route,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: routeControllersState(crear, creaControllers, state, context),
          transitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  static MultiProvider routeControllersState(
      Widget Function(GoRouterState state) crear,
      List<ChangeNotifierProvider> Function(GoRouterState state, BuildContext context)
          creaControllers,
      GoRouterState state,
      BuildContext context) {
    return MultiProvider(
        providers: creaControllers(state, context),
        child: Consumer<I18nProvider>(builder: (___, _, __) => crear(state)));
  }
}
