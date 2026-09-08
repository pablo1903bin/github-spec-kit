import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Superficie con glassmorphism sutil (blur + relleno semitransparente) para
/// elementos flotantes sobre contenido (bottom nav, botones circulares de
/// acción, headers) — adaptada 1:1 de sam-vision/FleetVision
/// (`presentation/global/widgets/design/glass_container.dart`), sin cambios
/// de comportamiento. Primer componente del Design System de este
/// proyecto (§10 PRESENTATION_ARCHITECTURE.md) — vive acá, no en un módulo,
/// porque cualquier módulo puede necesitarlo (§9.2, "widget global
/// reutilizable").
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.fillOpacity = 0.7,
    this.fillColor = Colors.black,
    this.borderColor,
    this.blurSigma = 14,
    this.shadowOpacity = 0.35,
    this.magnification = 1.0,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Opacidad del relleno (0 = solo blur, 1 = sólido). Bájala en elementos
  /// que flotan sobre contenido que debe seguir siendo legible.
  final double fillOpacity;

  /// Color base del relleno (negro por defecto). Un chip activo puede pasar
  /// el color de acento en vez de negro.
  final Color fillColor;

  /// Color del borde de 1px. Por defecto blanco 12% (el look "glass").
  final Color? borderColor;

  /// Intensidad del desenfoque. Subirlo tiene sentido sobre contenido con
  /// mucho detalle y `fillOpacity` bajo, para que el resultado siga
  /// leyéndose como vidrio y no como una ventana con el contenido de atrás
  /// demasiado nítido.
  final double blurSigma;

  /// Opacidad de la sombra exterior (negra). Bájala cuando la silueta debe
  /// sentirse flotando sobre el contenido, no enmarcada por un contorno
  /// oscuro definido.
  final double shadowOpacity;

  /// Zoom del contenido de atrás, centrado en el propio tamaño de la
  /// superficie (1.0 = sin cambio, el default — cero costo extra para los
  /// consumidores que no lo pasan). Sube apenas por encima de 1.0 (ej. 1.04)
  /// para una insinuación de lente/refracción sin un shader propio.
  final double magnification;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final filter = magnification == 1.0
            ? ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma)
            : ImageFilter.compose(
                outer: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                inner: ImageFilter.matrix(
                  _matrizZoomCentrado(magnification, constraints.biggest),
                  filterQuality: FilterQuality.medium,
                ),
              );

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: filter,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: fillColor.withValues(alpha: fillOpacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Escala `size` desde su propio centro (no desde el origen de pantalla)
  /// — sin esto, `ImageFilter.matrix` agranda desde la esquina (0,0) del
  /// layer filtrado y el contenido de atrás se ve corrido, no zoomeado en
  /// el lugar donde está la superficie.
  static Float64List _matrizZoomCentrado(double scale, Size size) {
    final dx = size.width / 2 * (1 - scale);
    final dy = size.height / 2 * (1 - scale);
    final matriz = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(dx, dy, 0);
    return matriz.storage;
  }
}
