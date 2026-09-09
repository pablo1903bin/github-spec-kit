import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_highlight_overlay_widget.dart';

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
/// **Nota de estado real (no lo que decían los comentarios viejos acá):**
/// [GlassContainer] tiene código para un fragment shader premium
/// (`shaders/glass_container.frag`) que nunca se activó — el asset no está
/// declarado en `pubspec.yaml`, así que `FragmentProgram.fromAsset` siempre
/// falla y el widget corre 100% del tiempo por su rama de respaldo:
/// `ImageFilter.blur` + un zoom centrado parejo (`ImageFilter.matrix`), sin
/// ninguna refracción real de bisel. `blurSigma`/`magnification` acá
/// controlan ESE mecanismo simple, no el shader. [GlassHighlightOverlay]
/// sigue siendo el único brillo real que se ve (el del shader nunca corrió).
/// Queda pendiente decidir si se termina de wirear el shader (declararlo en
/// `pubspec.yaml` y probarlo en un dispositivo real) o se retira el código
/// muerto — por ahora esta barra es un `BackdropFilter(blur)` simple, el
/// "vidrio falso" que el shader buscaba reemplazar.
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
          // CORRECCIÓN: el shader de `shaders/glass_container.frag` nunca
          // llegó a declararse en `pubspec.yaml` — sin eso,
          // `FragmentProgram.fromAsset` siempre falla y el widget cae al
          // mecanismo de respaldo (`ImageFilter.blur` + zoom vía
          // `ImageFilter.matrix`, ver `GlassContainer._buildFilter`). Todo
          // lo que describían los comentarios viejos acá sobre "el shader
          // mezcla esto o aquello" era código muerto que nunca corrió — la
          // opacidad real siempre vino de `blurSigma` (ver abajo), nunca del
          // shader. Pendiente: decidir si se declara el shader en pubspec y
          // se prueba de verdad, o se lo retira (§2, no dejar código muerto).
          fillColor: AppColors.white,
          fillOpacity: 0,
          // Bajado de 10 a 3: con fillOpacity/shadowOpacity ya casi en cero,
          // el blur era lo único que seguía "aplanando" el fondo en una
          // mancha pareja y pálida — sobre todo notorio ahora que Home tiene
          // fondo claro (poco contraste de por sí). Un blur bajo deja
          // reconocerse las formas/colores de atrás, que es lo que de
          // verdad se lee como "transparente" en vez de "blur homogéneo".
          blurSigma: 3,
          borderColor: AppColors.glassBorder(0.30),
          shadowOpacity: 0.02,
          // Rama sin shader (ver nota de arriba): esto sigue siendo un zoom
          // centrado parejo vía `ImageFilter.matrix`, no el bisel con
          // continuidad en el borde que describía el comentario anterior —
          // ese mecanismo es el del shader, que no está activo.
          magnification: 1.18,
          child: SizedBox(
            height: _alturaCapsula,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmento = tabs.isEmpty
                    ? 0.0
                    : constraints.maxWidth / tabs.length;

                return Stack(
                  children: [
                    // El shader de GlassContainer ya aporta su propio
                    // barrido de brillo direccional — esto solo suma un
                    // toque extra de reflejo en la cara interna del vidrio,
                    // no duplica el efecto.
                    const Positioned.fill(
                      child: GlassHighlightOverlay(opacity: 0.16),
                    ),
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
