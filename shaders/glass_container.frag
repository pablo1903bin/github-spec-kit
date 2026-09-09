// Vidrio limpio y premium para GlassContainer — UNA sola lente continua
// sobre toda la superficie (bisel de vidrio físico real), no gotas ni
// lluvia. Ver .claude/skills/flutter-glass-fx/SKILL.md y
// references/refraction-math.md.
//
// Built for dart:ui's `ImageFilter.shader(FragmentShader)` (BackdropFilter):
//   - El PRIMER uniform debe ser un vec2 — el engine lo pisa con el tamaño
//     real de la textura ligada. Igual lo seteamos desde Dart para cubrir
//     el primer frame.
//   - El PRIMER sampler2D lo liga el engine al contenido real de atrás.
//
// Todos los uniforms espaciales de acá (radio de esquina, ancho de banda de
// refracción, blur) son FRACCIONES de uSize, nunca píxeles absolutos: el
// engine no garantiza si uSize/FlutterFragCoord terminan en píxeles físicos
// o lógicos, así que un valor absoluto calculado del lado Dart (que solo
// conoce el tamaño lógico del widget) podría no coincidir con el espacio
// real del shader. Una fracción es correcta sin importar cuál sea, porque
// se reconstruye multiplicando por el propio uSize acá adentro.

#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;               // engine-set
uniform float uCornerRadiusFrac;  // radio de esquina / uSize.y
uniform float uRefractionStrength;// 0..1 — fuerza del bisel en el borde
uniform float uBlurFrac;          // radio de blur (muy chico) / uSize.y
uniform vec2 uLightDir;           // normalizado

uniform sampler2D uBackground;

out vec4 fragColor;

// SDF de rectángulo redondeado (Inigo Quilez): negativo adentro, 0 en el
// borde, positivo afuera.
float sdRoundedBox(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - halfSize + radius;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

vec3 sampleBackdrop(vec2 uv) {
  vec2 fixedUv = clamp(uv, 0.0, 1.0);
#ifdef IMPELLER_TARGET_OPENGLES
  fixedUv.y = 1.0 - fixedUv.y;
#endif
  return texture(uBackground, fixedUv).rgb;
}

// Blur de 4 muestras, deliberadamente barato y chico — esto es un vidrio
// limpio, no esmerilado: el punto es suavizar el detalle más fino sin
// volver el fondo una mancha.
vec3 softSample(vec2 uv, float pixelRadius) {
  if (pixelRadius < 0.5) return sampleBackdrop(uv);
  vec2 texel = pixelRadius / uSize;
  vec3 sum = sampleBackdrop(uv) * 0.4;
  sum += sampleBackdrop(uv + vec2(texel.x, 0.0)) * 0.15;
  sum += sampleBackdrop(uv - vec2(texel.x, 0.0)) * 0.15;
  sum += sampleBackdrop(uv + vec2(0.0, texel.y)) * 0.15;
  sum += sampleBackdrop(uv - vec2(0.0, texel.y)) * 0.15;
  return sum;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 uv = p / uSize;

  vec2 halfSize = uSize * 0.5;
  float radius = uCornerRadiusFrac * uSize.y;
  vec2 centered = p - halfSize;

  float dist = sdRoundedBox(centered, halfSize, radius); // <= 0 adentro
  float insideDist = -dist;

  // Lente convexa de verdad: un zoom RADIAL uniforme desde el centro del
  // panel, con un único requisito no negociable — en el borde REAL del
  // recorte (insideDist == 0) el zoom tiene que dar EXACTAMENTE 1.0.
  //
  // Ese borde es la costura entre "adentro" (pasa por este shader) y
  // "afuera" (contenido normal, sin filtrar, pintado por el resto del
  // árbol de widgets). Si el zoom ahí no es 1.0 -- como pasaba antes, con
  // un zoom base constante en todos lados y un empujón extra que además
  // era MÁXIMO justo en ese borde -- la muestra que toma el shader salta a
  // una posición distinta de la que pinta el contenido de afuera un
  // píxel más allá del recorte. Esa discontinuidad es exactamente lo que
  // se veía como una tarjeta duplicada/fantasma: dos posiciones de muestreo
  // distintas para el mismo punto de la escena, una a cada lado de la
  // costura. Por eso acá el zoom es una única curva continua que arranca en
  // 1.0 en el borde y solo crece hacia el centro -- nunca al revés, y nunca
  // una constante independiente de `insideDist`.
  // Banda de transición angosta -> el zoom llega a su valor pleno cerca
  // del borde (no recién a mitad del panel), así que la MAYOR PARTE del
  // vidrio visible muestra la lente, no solo una franja central angosta.
  float transitionBand = uSize.y * 0.30;
  float t = clamp(insideDist / transitionBand, 0.0, 1.0);
  float smoothT = t * t * (3.0 - 2.0 * t); // easing, no lineal: entrada suave

  // Magnitud real de la lente -- esto SÍ debe notarse (referencia: vidrio
  // premium con zoom/refracción visible, no transparencia lisa). Sigue
  // siendo 1.0 exacto en insideDist == 0 (el borde real del recorte) por la
  // misma razón de siempre: ahí es la costura con el contenido sin filtrar
  // de afuera, y esa continuidad es lo que evita la duplicación/ghosting.
  // La fuerza vive en cuánto crece hacia el centro, no en tocar ese punto.
  float totalZoom = 1.0 + uRefractionStrength * 0.30 * smoothT;

  // Mismo escalar para ambos ejes -> nunca hay corte/estiramiento diagonal,
  // solo una magnificación pareja hacia el centro, radial y continua.
  vec2 sampleUv = (halfSize + centered / totalZoom) / uSize;

  // Dirección radial (no la normal del borde más cercano) para modular el
  // brillo del filo más abajo — ver esa sección para el porqué.
  float distFromCenter = length(centered);
  vec2 unitFromCenter =
      distFromCenter > 0.5 ? centered / distFromCenter : vec2(0.0);

  float blurPx = uBlurFrac * uSize.y;
  vec3 clearColor = sampleBackdrop(sampleUv);
  vec3 softColor = softSample(sampleUv, blurPx);
  vec3 color = mix(clearColor, softColor, 0.30);

  // Cuerpo parejo del vidrio -- esta es la parte que faltaba. El rim y el
  // sheen de más abajo solo cubren una franja angosta cerca del borde y una
  // esquina; en una cápsula ANCHA Y BAJA como esta barra, esa franja es una
  // fracción chica del área total, así que casi toda la superficie
  // (el centro, lejos de cualquier borde) no recibía NINGÚN realce y sobre
  // un fondo oscuro se leía directamente como oscura/opaca -- por eso bajar
  // `fillOpacity` del lado Dart no cambiaba nada: el problema no era el
  // relleno, era que el shader no iluminaba el grueso del panel. Un mezclado
  // parejo hacia blanco en TODA la superficie (no solo cerca del borde) es
  // lo que un vidrio esmerilado/premium real hace -- dispersa luz ambiente
  // de forma pareja, no solo en el filo -- y es el mismo motivo por el que
  // la referencia se ve blanca/brillante en el cuerpo entero, no solo en
  // el borde.
  color = mix(color, vec3(1.0), 0.16);

  // Brillo especular justo en el borde real, encima del cuerpo parejo de
  // arriba -> un pop extra de luz en el bisel, no la única fuente de brillo
  // del panel. Modulado por la MISMA dirección radial de arriba (nunca la
  // normal del borde más cercano) para no reintroducir una dirección que
  // cambia entre el lado plano y la punta redondeada.
  float rim = 1.0 - smoothstep(0.0, uSize.y * 0.07, abs(insideDist));
  float rimLight = rim *
      clamp(dot(unitFromCenter, normalize(uLightDir)) * 0.5 + 0.5, 0.0, 1.0);
  color += vec3(rimLight * 0.30);

  // Anillo de sombra tenue, angosto y propio -- independiente del ancho de
  // la transición de zoom de arriba (no afecta ninguna posición de muestreo,
  // solo resta brillo, así que no puede causar duplicación/ghosting).
  float shadeBand = uSize.y * 0.10;
  float innerShade = smoothstep(0.0, shadeBand * 0.6, insideDist) *
      (1.0 - smoothstep(shadeBand * 0.6, shadeBand, insideDist));
  color -= vec3(innerShade * 0.03);

  // Barrido de brillo extra cerca de la esquina de luz. OJO: la distancia
  // se mide en PÍXELES reales (centered / uSize.y), no en `uv` crudo -- en
  // una cápsula mucho más ancha que alta, la distancia en `uv` normalizado
  // por eje comprime el eje X y expande el Y, así que ese brillo colapsaba
  // a casi nada en la mitad derecha del panel (ej. la pestaña "Perfil") en
  // vez de repartirse parejo con la forma real del panel.
  vec2 lightPx = (normalize(uLightDir) * 0.5 + 0.5) * uSize;
  float sheenDist = distance(p, lightPx) / uSize.y;
  float sheen = 1.0 - clamp(sheenDist, 0.0, 1.0);
  color += vec3(pow(sheen, 2.0) * 0.18);

  // Realce final de blancos: multiplicar por >1 (no por <1) es lo que le da
  // al vidrio esa sensación "luminosa" incluso sobre un fondo oscuro. Más
  // chico que antes porque el cuerpo parejo de arriba ya hace la mayor
  // parte del trabajo -- esto es solo el remate.
  color = color * vec3(1.02, 1.025, 1.03) + vec3(0.012, 0.013, 0.015);

  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
