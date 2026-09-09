import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_highlight_overlay_widget.dart';

/// Un ítem de la lista demo de [HomeView] — sin datos reales todavía, solo
/// para poder ver una lista larga desplazándose detrás del bottom nav (ver
/// `AppNavigationShell`). Se reemplaza por contenido real cuando exista.
///
/// Tarjeta de vidrio ([GlassContainer], no un `Card` sólido) — mismo
/// componente reutilizable que ya usa `AppBottomNavBar`, solo con otros
/// parámetros (más cuerpo/menos blur: acá el contenido debe ser legible al
/// instante, a diferencia de una barra flotante). Claro
/// (`AppColors.lightSurface`/`onLightSurface*`), no oscuro — sigue la misma
/// excepción puntual que [HomeView] (ver doc de
/// `AppColors.lightBackground`).
class HomeListItem extends StatelessWidget {
  const HomeListItem({super.key, required this.index});

  final int index;

  static const _borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        borderRadius: _borderRadius,
        fillColor: AppColors.lightSurface,
        // Más cuerpo que la barra flotante (0.45 vs. 0-0.04): acá el
        // contenido (título/subtítulo) tiene que leerse de inmediato sin
        // competir con lo que pase por detrás en el scroll.
        fillOpacity: 0.45,
        // Bajo a propósito, mismo criterio que la barra: suficiente para
        // sensación de vidrio, poco para que dos tarjetas seguidas se
        // mezclen entre sí en una sola mancha.
        blurSigma: 6,
        shadowOpacity: 0.08,
        child: Stack(
          children: [
            const Positioned.fill(
              child: GlassHighlightOverlay(opacity: 0.10),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elemento ${index + 1}',
                          style: const TextStyle(
                            color: AppColors.onLightSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Contenido de ejemplo — sin datos reales aún',
                          style: TextStyle(
                            color: AppColors.onLightSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
