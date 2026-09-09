import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';

/// Fila horizontal de accesos rápidos de ejemplo en [HomeView] — sin
/// acciones reales todavía (tocar un chip no hace nada). Cada chip reusa
/// [GlassContainer], mismo componente que ya usan `HomeListItem`/el AppBar/
/// `AppBottomNavBar` — ningún Widget nuevo de vidrio, solo otro consumidor
/// más.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  static const _acciones = [
    (icon: Icons.favorite_border, label: 'Favoritos'),
    (icon: Icons.history, label: 'Recientes'),
    (icon: Icons.settings_outlined, label: 'Ajustes'),
    (icon: Icons.download_outlined, label: 'Descargas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _acciones.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final accion = _acciones[index];
          return GlassContainer(
            borderRadius: 14,
            fillColor: AppColors.lightSurface,
            fillOpacity: 0.45,
            blurSigma: 6,
            shadowOpacity: 0.06,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: 84,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(accion.icon, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    accion.label,
                    style: const TextStyle(
                      color: AppColors.onLightSurface,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
