import 'package:flutter/material.dart';

/// Paleta de colores de la app — tema oscuro con acento verde, inspirado en
/// Spotify (negro casi puro + verde de marca). Token estático del sistema
/// visual (sin `BuildContext`, sin estado, sin Widget) — vive en
/// `core/theme/` junto a `ScreenBreakpoints`/`ScreenClass`, mismo criterio
/// que sam-vision/FleetVision documenta en PRESENTATION_ARCHITECTURE.md
/// §10.4. Úsala siempre en lugar de colores hardcodeados.
class AppColors {
  const AppColors._();

  // ── Primario (verde de marca) ───────────────────────────────────────────
  static const primary = Color(0xFF1DB954); // "Spotify Green"
  static const primaryLight = Color(0xFF1ED760); // estado hover/pressed
  static const primaryDark = Color(0xFF168F42);

  // ── Neutros (superficies oscuras) ───────────────────────────────────────
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF181818);
  static const surfaceVariant = Color(0xFF282828);
  static const onSurface = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFFB3B3B3);

  // ── Texto (propósito explícito) ─────────────────────────────────────────
  static const textPrimary = onSurface; // títulos y contenido principal
  static const textSecondary = onSurfaceVariant; // subtítulos, hints, captions
  static const textDisabled = Color(0xFF6A6A6A);

  // ── Líneas / sombras ─────────────────────────────────────────────────────
  static const divider = Color(0x1FFFFFFF); // blanco 12%
  static const shadow = Color(0x99000000); // negro 60%

  // ── Estado ───────────────────────────────────────────────────────────────
  static const success = primary;
  static const error = Color(0xFFE91429);
  static const warning = Color(0xFFF59B23);
  static const info = Color(0xFF509BF5);

  static const white = Colors.white;
  static const black = Colors.black;

  // ── Gradientes reutilizables ─────────────────────────────────────────────

  /// Fondo degradado oscuro (base de cualquier pantalla "hero", ej. Home) —
  /// mismo recurso visual que usa Spotify en sus vistas principales.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A2A), background],
    stops: [0.0, 0.6],
  );

  // ── Helpers de opacidad ──────────────────────────────────────────────────
  static Color glass([double opacity = 0.06]) => white.withValues(alpha: opacity);
  static Color glassBorder([double opacity = 0.12]) =>
      white.withValues(alpha: opacity);
}
