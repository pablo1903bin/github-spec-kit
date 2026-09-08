import 'package:flutter/material.dart';

/// Identidad de cada pestaña del bottom nav. Antes era una clase `NavTab`
/// más una lista aparte (`_appTabs`) — pasó a ser un enum porque el
/// conjunto de pestañas es cerrado y se conoce en tiempo de compilación
/// (nunca viene del backend ni cambia en runtime): exactamente el caso de
/// uso de un enum en Dart, no el de una lista de objetos de valor.
///
/// Cada valor lleva sus propios datos vía constructor `const` ("enhanced
/// enum") — evita mantener una clase de datos y una lista aparte
/// sincronizadas a mano.
///
/// [AppTab.values] ES el orden oficial de las pestañas — `routes.dart`
/// construye sus `StatefulShellBranch` iterando este mismo enum (ver
/// `_routeFor` ahí), así que agregar una pestaña nueva ya no puede
/// desincronizar "qué se ve en la barra" de "a qué ruta navega": el switch
/// exhaustivo de Dart sobre un enum obliga a cablear la ruta de cualquier
/// valor nuevo, o el proyecto no compila.
///
/// Sin campo `id`: el propio `.name` del enum (`AppTab.home.name ==
/// 'home'`) ya es un identificador estable si alguna vez hace falta uno.
/// Sin campo `route`: nunca se leía (era puramente decorativo) — la única
/// responsabilidad real de "a qué ruta navega cada pestaña" vive en
/// `routes.dart`, no acá.
///
/// Vive en `widgets/` (no en `catalog/`) por el mismo motivo que
/// documentaba `NavTab`: `navigation/` no es un "módulo de catálogo" en el
/// sentido de PRESENTATION_ARCHITECTURE.md §5.1.
enum AppTab {
  home(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Inicio',
  ),
  profile(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Perfil',
  );

  const AppTab({required this.icon, this.selectedIcon, required this.label});

  final IconData icon;

  /// Ícono alterno cuando está seleccionada (patrón M3 outlined→filled). Si
  /// es null, se usa [icon] siempre.
  final IconData? selectedIcon;

  final String label;
}
