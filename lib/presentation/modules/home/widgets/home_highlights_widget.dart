import 'package:flutter/material.dart';

/// Carrusel horizontal de tarjetas destacadas de ejemplo en [HomeView] — a
/// diferencia de [HomeListItem]/`HomeQuickActions` (vidrio), estas son
/// tarjetas SÓLIDAS de color con gradiente, a propósito: le dan al
/// `AppBottomNavBar`/al AppBar del vidrio otro tipo de contenido real
/// detrás cuando el usuario hace scroll, no solo tarjetas de vidrio
/// repetidas. Sin datos reales todavía — se reemplaza por contenido real
/// cuando exista.
class HomeHighlights extends StatelessWidget {
  const HomeHighlights({super.key});

  static const _gradientes = [
    [Color(0xFF1DB954), Color(0xFF168F42)], // verde de marca
    [Color(0xFFE91429), Color(0xFF8E0C1A)], // rojo
    [Color(0xFF509BF5), Color(0xFF1E5CA8)], // azul
    [Color(0xFFF59B23), Color(0xFFB86E10)], // ámbar
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _gradientes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientes[index],
              ),
            ),
            child: Text(
              'Destacado ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
