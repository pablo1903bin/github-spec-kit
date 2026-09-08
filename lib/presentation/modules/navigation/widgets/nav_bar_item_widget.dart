import 'package:flutter/material.dart';

/// Un ítem (ícono + etiqueta) de [AppBottomNavBar] — extraído a su propio
/// archivo (§9.2) por el mismo motivo que [NavBarHighlight]: mantener
/// `app_bottom_nav_bar_widget.dart` enfocado solo en ensamblar la barra.
///
/// Público (no `_NavItem`) por la misma razón que [NavBarHighlight]: sigue
/// siendo un detalle interno de `AppBottomNavBar`, no pensado para
/// reutilizarse fuera de `navigation/widgets/`.
class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.unselectedColor,
    required this.onTap,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final Color color;
  final Color unselectedColor;
  final VoidCallback onTap;

  static const _duracion = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final colorActual = selected ? color : unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: _duracion,
              style: TextStyle(color: colorActual),
              child: Icon(selected ? (selectedIcon ?? icon) : icon),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: _duracion,
              style: TextStyle(
                color: colorActual,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
