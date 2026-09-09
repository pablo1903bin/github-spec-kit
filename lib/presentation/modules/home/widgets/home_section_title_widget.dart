import 'package:flutter/material.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';

/// Título de una sección dentro de [HomeView] (ej. "Destacados", "Todo") —
/// mismo estilo en toda la pantalla, para no repetir un `TextStyle` inline
/// cada vez que se agrega una sección nueva.
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onLightSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
