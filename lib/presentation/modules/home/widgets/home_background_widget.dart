import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Fondo decorativo detrás de la lista de [HomeView] — manchas de color
/// simples, sin ningún dato real. Sin esto, el fondo era un tono plano
/// único (`AppColors.lightBackground`) y el efecto de vidrio de
/// `AppBottomNavBar`/el `AppBar`/`HomeListItem` no se distinguía: un vidrio
/// transparente sobre un color parejo se ve igual de parejo. Este fondo le
/// da variación real de color para que el blur/la transparencia se note al
/// desplazarse por debajo. Se reemplaza el día que Home tenga contenido
/// real (una imagen, un banner, etc.).
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  static const _size = 240.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.onSurface),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -50,
            child: _blob(AppColors.primary.withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 220,
            right: -90,
            child: _blob(AppColors.primaryDark.withValues(alpha: 0.30)),
          ),
          Positioned(
            bottom: 220,
            left: -70,
            child: _blob(AppColors.primaryLight.withValues(alpha: 0.30)),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: _blob(AppColors.primary.withValues(alpha: 0.22)),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
