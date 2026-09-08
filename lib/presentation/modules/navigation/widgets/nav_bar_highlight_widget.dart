import 'package:flutter/material.dart';

/// Cápsula de resalte detrás de la pestaña activa de [AppBottomNavBar] —
/// extraída a su propio archivo (§9.2) para que `app_bottom_nav_bar_widget.dart`
/// se quede solo con el ensamblaje de la barra.
///
/// Público (no `_NavHighlight`) únicamente porque una clase privada de un
/// archivo no es visible desde otro — sigue siendo un detalle interno de
/// `AppBottomNavBar`, no un componente pensado para reutilizarse fuera de
/// `navigation/widgets/`.
class NavBarHighlight extends StatelessWidget {
  const NavBarHighlight({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
