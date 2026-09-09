import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Superficie con glassmorphism para elementos flotantes sobre contenido
/// (bottom nav, botones circulares de acción, headers) — adaptada
/// originalmente de sam-vision/FleetVision
/// (`presentation/global/widgets/design/glass_container.dart`). Primer
/// componente del Design System de este proyecto (§10
/// PRESENTATION_ARCHITECTURE.md) — vive acá, no en un módulo, porque
/// cualquier módulo puede necesitarlo (§9.2, "widget global reutilizable").
///
/// **Vidrio real, no un panel gris difuminado.** Sigue el criterio de
/// `.claude/skills/flutter-glass-fx/SKILL.md`: un `BackdropFilter(blur) +
/// Container` liso es "vidrio falso" — el vidrio real es transparente
/// (el contenido de atrás se sigue viendo con sus colores y formas), y
/// dobla la luz en vez de solo difuminarla. Por eso, cuando el dispositivo
/// corre el renderer Impeller
/// ([ImageFilter.isShaderFilterSupported] en `true` — Android/iOS desde
/// Flutter 3.29), este widget usa un fragment shader
/// (`shaders/glass_container.frag`) que aplica una única lente continua
/// sobre toda la superficie en vez de un blur uniforme: el centro del panel
/// queda casi sin distorsionar (transparencia real), y la refracción se
/// concentra cerca del borde redondeado — como el bisel de un vidrio físico
/// real, no como una gota. Ver
/// `.claude/skills/flutter-glass-fx/references/refraction-math.md` y
/// `references/glsl-shader-guide.md`.
///
/// Sin Impeller (`isShaderFilterSupported` en `false`), se degrada al
/// mecanismo anterior — blur uniforme + zoom centrado vía
/// `ImageFilter.matrix` — en vez de fallar. Esa rama es un salvavidas de
/// compatibilidad, no el efecto que este widget busca dar por defecto.
class GlassContainer extends StatefulWidget {
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

  /// Intensidad del desenfoque. Con el shader activo esto es deliberadamente
  /// sutil (unos pocos px reales, ver `_writeUniforms`) — suficiente para
  /// suavizar el detalle fino sin volver el fondo una mancha uniforme; en la
  /// rama sin Impeller sigue siendo el sigma real de `ImageFilter.blur`.
  final double blurSigma;

  /// Opacidad de la sombra exterior (negra). Bájala cuando la silueta debe
  /// sentirse flotando sobre el contenido, no enmarcada por un contorno
  /// oscuro definido.
  final double shadowOpacity;

  /// Cuánto "dobla la luz" el vidrio cerca de su borde redondeado (1.0 =
  /// sin refracción). Con el shader activo controla la fuerza de la lente
  /// del bisel (ver doc de clase); en la rama sin Impeller sigue siendo el
  /// zoom centrado de siempre vía `ImageFilter.matrix`. Mismo parámetro,
  /// mismo significado conceptual ("insinuación de lente/refracción") en
  /// ambos mecanismos — solo cambia cómo se logra.
  final double magnification;

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  static const _shaderAsset = 'shaders/glass_container.frag';
  static Future<FragmentProgram>? _programFuture;

  FragmentShader? _shader;
  bool _shaderUnavailable = false;

  bool get _useShader => _shader != null && !_shaderUnavailable;

  @override
  void initState() {
    super.initState();
    if (ImageFilter.isShaderFilterSupported) {
      _loadShader();
    } else {
      // Backend sin Impeller (ver doc de clase) -> ni siquiera se intenta
      // cargar el asset, directo a la rama de compatibilidad.
      _shaderUnavailable = true;
    }
  }

  Future<void> _loadShader() async {
    try {
      _programFuture ??= FragmentProgram.fromAsset(_shaderAsset);
      final program = await _programFuture!;
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // Asset no compilado en esta plataforma -> degradar, no tirar la app
      // abajo (ver `references/glsl-shader-guide.md` §1).
      if (mounted) setState(() => _shaderUnavailable = true);
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: _buildFilter(size),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.fillColor.withValues(alpha: widget.fillOpacity),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor ?? Colors.white.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.shadowOpacity),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  ImageFilter _buildFilter(Size size) {
    if (_useShader) {
      return ImageFilter.shader(_writeUniforms(_shader!, size));
    }

    return widget.magnification == 1.0
        ? ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma)
        : ImageFilter.compose(
            outer: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
            inner: ImageFilter.matrix(
              _matrizZoomCentrado(widget.magnification, size),
              filterQuality: FilterQuality.medium,
            ),
          );
  }

  /// Dirección de luz implícita (arriba-izquierda) para el brillo/reflejo
  /// del shader — fija a propósito, igual criterio que cualquier otra
  /// superficie de vidrio de la app debería mantener (ver
  /// `flutter-glass-fx/SKILL.md` § "What NOT to do").
  static const _lightDir = Offset(-0.5, -0.7);

  FragmentShader _writeUniforms(FragmentShader shader, Size size) {
    var i = 0;
    void setFloat(double value) => shader.setFloat(i++, value);

    setFloat(size.width); // uSize.x — el engine lo pisa igual (ver guía del
    setFloat(size.height); // shader), pero cubre el primer frame.

    // Todo lo espacial de acá en adelante son FRACCIONES de `size`, nunca
    // píxeles absolutos: el engine no garantiza si `uSize`/`FlutterFragCoord`
    // terminan siendo píxeles físicos o lógicos, así que cualquier valor
    // absoluto calculado del lado Dart podría no coincidir con el espacio
    // real del shader. Una fracción es correcta sin importar cuál sea —
    // ver el comentario equivalente en `shaders/glass_container.frag`.
    setFloat((widget.borderRadius / size.height).clamp(0.0, 0.5)); // uCornerRadiusFrac
    final refraction = ((widget.magnification - 1.0) * 5.0).clamp(0.0, 1.0);
    setFloat(refraction); // uRefractionStrength
    setFloat((widget.blurSigma / size.height).clamp(0.0, 0.05)); // uBlurFrac

    final light = _lightDir / _lightDir.distance;
    setFloat(light.dx); // uLightDir.x
    setFloat(light.dy); // uLightDir.y

    return shader;
  }

  /// Escala `size` desde su propio centro (no desde el origen de pantalla)
  /// — sin esto, `ImageFilter.matrix` agranda desde la esquina (0,0) del
  /// layer filtrado y el contenido de atrás se ve corrido, no zoomeado en
  /// el lugar donde está la superficie. Solo usado por la rama sin Impeller
  /// (ver [_buildFilter]).
  static Float64List _matrizZoomCentrado(double scale, Size size) {
    final dx = size.width / 2 * (1 - scale);
    final dy = size.height / 2 * (1 - scale);
    final matriz = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(dx, dy, 0);
    return matriz.storage;
  }
}
