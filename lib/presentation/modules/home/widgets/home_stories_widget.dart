import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Fila horizontal de "historias" de ejemplo en [HomeView] — círculos con
/// anillo de acento, sin contenido real todavía (ni imagen ni usuario
/// real). Se reemplaza por contenido real cuando exista.
class HomeStories extends StatelessWidget {
  const HomeStories({super.key});

  static const _nombres = [
    'Vos',
    'Ana',
    'Luis',
    'Sofía',
    'Marco',
    'Carla',
    'Diego',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _nombres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 64,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primaryDark],
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.lightSurface,
                    child: Text(
                      _nombres[index][0],
                      style: const TextStyle(
                        color: AppColors.onLightSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _nombres[index],
                  style: const TextStyle(
                    color: AppColors.onLightSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
