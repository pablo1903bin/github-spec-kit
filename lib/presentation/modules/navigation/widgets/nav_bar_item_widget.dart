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

  /// Sombra fija (siempre presente, sin importar `selected`) para que el
  /// ícono/etiqueta se distingan sin importar qué color de fondo esté
  /// pasando detrás de la barra en ese momento del scroll (ver doc de
  /// [AppBottomNavBar] — la barra es casi transparente, así que el fondo
  /// real puede ser cualquier color de `HomeHighlights`/`HomeBanner`/etc.).
  /// Un texto/ícono verde sobre una tarjeta verde se pierde por más
  /// contraste que tenga su propio color — el borde oscuro es lo único que
  /// lo separa del fondo sin importar de qué color sea.
  static const _sombra = [
    Shadow(color: Colors.black45, blurRadius: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final colorActual = selected ? color : unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BUG real: `Icon` no lee color de `DefaultTextStyle` (eso solo
            // afecta a `Text`) — envolverlo en `AnimatedDefaultTextStyle`
            // no hacía nada, el ícono seguía cayendo al color del
            // `IconTheme` global (blanco). `Icon.color` es el único
            // parámetro que realmente lo pinta — acá con
            // `TweenAnimationBuilder` para conservar la transición animada.
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: colorActual),
              duration: _duracion,
              builder: (context, color, _) => Icon(
                selected ? (selectedIcon ?? icon) : icon,
                color: color,
                shadows: _sombra,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: _duracion,
              style: TextStyle(
                color: colorActual,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                shadows: _sombra,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
