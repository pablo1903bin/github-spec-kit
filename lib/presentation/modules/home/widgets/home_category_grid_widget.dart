import 'package:flutter/material.dart';

/// Grilla 2x2 de categorías de ejemplo en [HomeView] — tarjetas sólidas de
/// color, sin scroll propio (usa `GridView` con `shrinkWrap` porque vive
/// adentro del `CustomScrollView` de la Page, no tiene su propio scroll).
/// Sin datos reales todavía — se reemplaza por contenido real cuando
/// exista.
class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({super.key});

  static const _categorias = [
    (label: 'Música', color: Color(0xFF1DB954), icon: Icons.music_note),
    (label: 'Podcasts', color: Color(0xFF509BF5), icon: Icons.mic),
    (label: 'Videos', color: Color(0xFFE91429), icon: Icons.play_circle),
    (label: 'Radio', color: Color(0xFFF59B23), icon: Icons.radio),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categorias.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final categoria = _categorias[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: categoria.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(categoria.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                categoria.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
