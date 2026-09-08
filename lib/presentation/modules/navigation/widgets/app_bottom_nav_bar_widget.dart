import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';

import 'app_tab.dart';
import 'nav_bar_highlight_widget.dart';
import 'nav_bar_item_widget.dart';

/// Barra de navegación inferior — adaptada de sam-vision/FleetVision
/// (`navigation/widgets/app_bottom_nav_bar_widget.dart`). Cápsula flotante
/// de vidrio ([GlassContainer], no un `Material` sólido) con margen a los
/// cuatro lados — para que se vea como vidrio de verdad, quien monte esta
/// barra debe usar `Scaffold(extendBody: true)` (ver `AppNavigationShell`):
/// sin eso no hay contenido real detrás para desenfocar, y el blur solo
/// difuminaría el color de fondo del Scaffold.
///
/// Mismo mecanismo central que el original: una cápsula que se DESLIZA
/// (`AnimatedPositioned`) entre pestañas en vez de resaltarlas una por una
/// (ver [NavBarHighlight]).
///
/// Recortado a propósito respecto al original: sin pestañas de "acción" (ver
/// doc de [AppTab]) — acá todas las pestañas navegan, no existe todavía el
/// concepto de acción-sin-navegar.
///
/// Solo ensambla — [NavBarHighlight] y [NavBarItem] viven en sus propios
/// archivos (§9.2) para que este quede corto y enfocado en el layout de la
/// barra, no en el detalle visual de cada pieza.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSeleccionar,
  });

  final List<AppTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSeleccionar;

  static const _alturaCapsula = 62.0;

  /// Aire entre la cápsula y el resto de la pantalla — lo que la hace sentir
  /// flotante en vez de pegada a los bordes. Valores fijos (no tokens de
  /// `AppDimensions`) porque ese sistema de espaciados todavía no existe en
  /// este proyecto — el día que exista, esto migra a esos tokens.
  static const _margenVertical = 12.0;
  static const _margenHorizontal = 16.0;

  /// Alto TOTAL reservado por esta barra (sin el safe-area inferior, que
  /// cada pantalla ya conoce por su cuenta vía `MediaQuery`) — público para
  /// que el contenido que queda detrás (ej. el padding inferior de una
  /// lista, ver `HomeView`) sepa cuánto espacio dejar libre para que sus
  /// últimos elementos no queden tapados por la cápsula.
  static const altura = _alturaCapsula + _margenVertical * 2;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: altura + bottomPad,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _margenHorizontal,
          _margenVertical,
          _margenHorizontal,
          _margenVertical + bottomPad,
        ),
        child: GlassContainer(
          borderRadius: _alturaCapsula / 2,
          fillColor: AppColors.surface,
          fillOpacity: 0.55,
          blurSigma: 20,
          borderColor: AppColors.glassBorder(),
          shadowOpacity: 0.35,
          child: SizedBox(
            height: _alturaCapsula,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmento = tabs.isEmpty
                    ? 0.0
                    : constraints.maxWidth / tabs.length;

                return Stack(
                  children: [
                    if (currentIndex >= 0 && currentIndex < tabs.length)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        left: currentIndex * segmento,
                        width: segmento,
                        top: 8,
                        bottom: 8,
                        child: const NavBarHighlight(color: AppColors.primary),
                      ),
                    Row(
                      children: [
                        for (final (index, tab) in tabs.indexed)
                          NavBarItem(
                            icon: tab.icon,
                            selectedIcon: tab.selectedIcon,
                            label: tab.label,
                            selected: index == currentIndex,
                            color: AppColors.primary,
                            unselectedColor: AppColors.textSecondary,
                            onTap: () => onSeleccionar(index),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
