import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Banner ancho de ejemplo en [HomeView] — una única tarjeta grande con
/// degradado, distinta de todo lo demás en la pantalla (ni vidrio, ni
/// carrusel, ni grilla) para sumar variedad real de contenido detrás del
/// bottom nav/AppBar. Sin acción real todavía — se reemplaza cuando exista
/// contenido real.
class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Probá algo nuevo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Contenido de ejemplo — sin datos reales aún',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome, color: Colors.white, size: 36),
        ],
      ),
    );
  }
}
