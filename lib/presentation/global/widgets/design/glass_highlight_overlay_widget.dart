import 'package:flutter/material.dart';

/// Reflejo superior muy tenue sobre una superficie de vidrio
/// (`GlassContainer`) — la sensación de "brillo húmedo" de un vidrio real,
/// no un contorno dibujado. Puramente decorativo (`IgnorePointer`) — se
/// apoya sobre el `ClipRRect` que ya trae `GlassContainer`, así que no
/// necesita el suyo propio.
///
/// Adaptado de sam-vision/FleetVision (antes `_GlassHighlightOverlay`,
/// privado de `app_bottom_nav_bar_widget.dart`) — pasa al Design System
/// porque cualquier superficie de vidrio de la app puede necesitarlo, no
/// solo el bottom nav (§9.2 PRESENTATION_ARCHITECTURE.md: "widget global
/// reutilizable" cuando no depende de nada específico de un módulo).
class GlassHighlightOverlay extends StatelessWidget {
  const GlassHighlightOverlay({super.key, this.opacity = 0.12});

  /// Intensidad del brillo superior. Súbela sobre fondos ya de por sí claros
  /// o muy coloridos (necesitan más contraste para notarse) y bájala sobre
  /// fondos oscuros, donde un blanco tenue ya resalta solo.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: opacity),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
