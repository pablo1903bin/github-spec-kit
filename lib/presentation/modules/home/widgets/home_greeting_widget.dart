import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Encabezado de bienvenida de [HomeView] — texto de ejemplo (sin nombre de
/// usuario ni hora del día real todavía). Se reemplaza por contenido real
/// cuando exista.
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola 👋',
          style: TextStyle(
            color: AppColors.onLightSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Esto es lo nuevo para vos',
          style: TextStyle(
            color: AppColors.onLightSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
