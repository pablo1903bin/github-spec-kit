import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Un ítem de la lista demo de [HomeView] — sin datos reales todavía, solo
/// para poder ver una lista larga desplazándose detrás del bottom nav (ver
/// `AppNavigationShell`). Se reemplaza por contenido real cuando exista.
class HomeListItem extends StatelessWidget {
  const HomeListItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Elemento ${index + 1}'),
        subtitle: const Text('Contenido de ejemplo — sin datos reales aún'),
      ),
    );
  }
}
