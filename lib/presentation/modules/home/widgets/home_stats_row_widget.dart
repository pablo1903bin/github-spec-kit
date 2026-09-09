import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';

/// Fila de estadísticas de ejemplo en [HomeView] — tres tarjetas de vidrio
/// con un número y una etiqueta, sin datos reales todavía. Reusa
/// [GlassContainer] (mismo criterio que el resto de Home: ningún widget de
/// vidrio nuevo, solo otro consumidor).
class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({super.key});

  static const _stats = [
    (valor: '128', etiqueta: 'Completados'),
    (valor: '32h', etiqueta: 'Esta semana'),
    (valor: '#4', etiqueta: 'Racha'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final stat in _stats) ...[
          Expanded(child: _StatCard(stat: stat)),
          if (stat != _stats.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ({String valor, String etiqueta}) stat;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 14,
      fillColor: AppColors.lightSurface,
      fillOpacity: 0.45,
      blurSigma: 6,
      shadowOpacity: 0.06,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            stat.valor,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.etiqueta,
            style: const TextStyle(
              color: AppColors.onLightSurfaceVariant,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
