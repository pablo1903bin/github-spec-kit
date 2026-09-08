# FleetVision - Arquitectura de Módulos (Presentation)

Este documento define las reglas oficiales para construir y mantener la capa **Presentation** de FleetVision.

Es el documento hermano de [`domain/DOMAIN_ARCHITECTURE.md`](../domain/DOMAIN_ARCHITECTURE.md) y comparte su misma filosofía y nivel de exigencia.

Existen además dos documentos especializados (misma carpeta), que profundizan en casos concretos de las reglas §9.5 y §10.5 de este documento sin repetir sus reglas generales — las aplican:

- [`NAVIGATION_ARCHITECTURE.md`](NAVIGATION_ARCHITECTURE.md) — cómo `presentation/modules/navigation/` decide entre Drawer/Sidebar/BottomNavigation.
- [`MAP_ARCHITECTURE.md`](MAP_ARCHITECTURE.md) — cómo `presentation/modules/mapa/` decide entre `CompactMapLayout` (panel arrastrable táctil) y `DesktopMapLayout` (paneles fijos de dispositivos/detalle a los costados del mapa).

Su objetivo es que cualquier persona (o IA) pueda abrir `presentation/` y entender, sin contexto externo, cómo se construye una pantalla, dónde vive cada responsabilidad y por qué.

Este documento es la **fuente oficial de verdad** para la arquitectura de la capa Presentation. Ninguna implementación puede contradecirlo.

Si una necesidad real requiere modificar estas reglas, primero debe actualizarse este documento y, una vez aprobado el cambio, implementarse el código correspondiente.

---

# 1. Introducción

Presentation es la capa que traduce el estado de la aplicación en una interfaz de usuario, y las acciones del usuario en operaciones sobre Domain. No decide reglas de negocio, no habla HTTP, no persiste nada por sí misma — coordina.

Un módulo de Presentation (`mapa`, `login`, `tracking`, `devices`, etc.) es la unidad de organización de esta capa: agrupa el Controller, el State, las Pages y los Widgets que conforman una pantalla o un flujo. Cada módulo se lee de forma aislada; nada obliga a saltar a otro módulo para entender el suyo.

---

# 2. Filosofía

Toda la capa Presentation se apoya en un puñado de principios no negociables:

- **Cada clase tiene una única responsabilidad claramente identificable.** El nombre de una clase debe describir esa responsabilidad, nunca el dato que transporta ni una implementación interna.
- **La simplicidad tiene prioridad sobre la generalización.** Se resuelve el problema real de hoy, no una hipótesis de mañana.
- **No se crean abstracciones "por si acaso".** Una interfaz, un mixin o una capa nueva necesitan un consumidor real, no una posibilidad futura.
- **No se crean carpetas nuevas sin una necesidad arquitectónica real.** La estructura de un módulo (§4) es fija; desviarse de ella requiere una justificación explícita.
- **Toda decisión busca sostener una arquitectura consistente durante muchos años.** Se prefiere un poco más de código explícito hoy a una abstracción que nadie recuerde por qué existe dentro de dos años.

---

# 3. Principios arquitectónicos

Estos principios se derivan de la filosofía y rigen cada regla concreta del resto del documento:

- **Responsabilidad única.** Un Controller coordina, un State representa, una Page ensambla, un Widget dibuja. Ninguno invade el rol del otro.
- **Bajo acoplamiento, alta cohesión.** Un módulo puede modificarse sin que ese cambio se propague a otros módulos.
- **Una única fuente de verdad por pantalla.** El State — nunca variables paralelas en el Controller ni en el Widget.
- **Comunicación unidireccional y sin atajos.** Widget → Controller → Repository (§11), sin excepciones "por comodidad".
- **Reutilización antes que reinvención.** Antes de crear un Widget o un patrón nuevo, se verifica si el Design System o un módulo existente ya lo resuelven (§10).
- **Nombres que se explican solos.** Un archivo o una clase deben delatar su tipo y su responsabilidad con solo leer su nombre (§13).

---

# 4. Estructura oficial de módulos

Todo módulo debe seguir esta estructura, sin carpetas adicionales — salvo el caso descrito en §5 (Módulos de catálogo), la única excepción documentada:

```
presentation/
└── modules/
    └── nombre_modulo/
        ├── controllers/
        │     mapa_controller.dart
        │     │
        │     └── state/
        │           mapa_state.dart
        │
        ├── pages/
        │     mapa_view.dart
        │
        └── widgets/
              mapa_top_bar_widget.dart
              mapa_view_widget.dart
              device_selector_widget.dart
```

Cada carpeta admite un único tipo de contenido:

| Carpeta | Contiene únicamente |
|---|---|
| `controllers/` | Controllers (`StateNotifier<TState>`) — ver §6 |
| `controllers/state/` | Clases State con Freezed — ver §7 |
| `pages/` | La(s) vista(s) principal(es) del módulo — ver §8 |
| `widgets/` | Widgets propios del módulo — ver §9 |

`state/` vive anidada dentro de `controllers/`, nunca como carpeta hermana: una clase State no existe sin el Controller que la administra (§6.2 — es su única fuente de verdad), así que la carpeta que la contiene refleja esa pertenencia en vez de sugerir que es un tipo de dato independiente y reutilizable por separado.

Ningún archivo se coloca fuera de la carpeta que corresponde a su tipo, y ninguna carpeta contiene un tipo de clase distinto al que le corresponde.

Cuando la pantalla principal de un módulo necesita árboles de Widgets estructuralmente distintos según `ScreenClass`, `widgets/` admite una única subcarpeta adicional, `layouts/` — ver §9.5, la convención oficial de todo SAMVision para este caso (no exclusiva de un módulo puntual):

```
presentation/
└── modules/
    └── nombre_modulo/
        ├── controllers/
        │     nombre_modulo_controller.dart
        │     │
        │     └── state/
        │           nombre_modulo_state.dart
        │
        ├── pages/
        │     nombre_modulo_view.dart
        │
        └── widgets/
              nombre_modulo_widget.dart
              │
              └── layouts/
                    ├── compact/
                    │     compact_nombre_modulo_layout.dart
                    │
                    └── desktop/
                          desktop_nombre_modulo_layout.dart
```

---

# 5. Módulos de catálogo (ensamblaje de variantes)

## 5.1. Qué es un módulo de catálogo

Un módulo califica como **módulo de catálogo** únicamente cuando:

- expone más de una variante estructuralmente completa de su experiencia (no una simple rama de UI dentro de la misma pantalla);
- decidir qué variante mostrar es, en sí mismo, parte de la responsabilidad del módulo;
- cada variante compone Controllers/Widgets/Views que ya existen en otros módulos — nunca los reimplementa.

Esta calificación es la **única** justificación arquitectónica válida para agregar las dos carpetas de §5.2 (ver §15 — "no se crean nuevas categorías sin justificación clara y sin actualizar primero este documento"). Hoy el único módulo que califica es `workspace/`.

## 5.2. Estructura adicional autorizada

```
presentation/
└── modules/
    └── workspace/
        ├── controllers/        (§4 — sin cambios)
        ├── catalog/            ← módulo de catálogo
        │     workspace_catalog.dart
        │     workspace_ensamblado.dart
        │     dashboard_configuration.dart
        │     workspace_identity.dart
        │     workspace_tab.dart
        │     workspace_dependencies.dart
        │     workspace_quick_action.dart
        │     estructura_signals.dart
        │
        └── dashboards/         ← módulo de catálogo
              owner_dashboard.dart
              conductor_dashboard.dart
              monitor_dashboard.dart
```

Ningún otro módulo puede crear `catalog/` ni una carpeta de ensamblaje sin cumplir §5.1.

## 5.3. `catalog/`: contrato de variante + registro

Contiene dos tipos de clases:

**a) Modelos de configuración de variante.** Objetos de valor inmutables (Freezed, igual que un State — ver §7) que describen QUÉ necesita una variante para existir — nunca CÓMO se ve ni CÓMO se comporta una pantalla puntual. Ejemplo: `WorkspaceIdentity` (título/ícono/color de una variante), `WorkspaceTab` (una pestaña del bottom nav), `DashboardConfiguration` (identidad + pestañas + overlays de una variante), `WorkspaceDependencies` (qué Providers necesita), `WorkspaceEnsamblado` (agrupa todo lo anterior), `WorkspaceQuickAction`, `EstructuraSignals`.

A diferencia de un modelo de Domain, un modelo de configuración de `catalog/` **sí puede** referenciar tipos de Flutter (`IconData`, `Color`, `WidgetBuilder`, `VoidCallback`, `Widget Function(...)`) — Presentation ya puede depender de Flutter (§12), y describir "qué Widget arma esta pestaña" es exactamente el tipo de dato que un módulo de catálogo necesita transportar. Esto es lo que los saca de Domain: `DOMAIN_ARCHITECTURE.md` prohíbe expresamente estos tipos ahí.

Reglas:

- inmutables, con Freezed, igual criterio que §7 (State);
- no contienen lógica de negocio;
- no acceden a Data/HTTP/SQLite directamente;
- no son State de ningún Controller — no los actualiza nadie con `copyWith()` en respuesta a un evento de UI; se construyen una sola vez y no vuelven a cambiar.

**b) El registro (catálogo) en sí.** Una única clase por módulo (ej. `WorkspaceCatalog`) que mapea el discriminador del módulo (ej. `WorkspaceMode`) a su modelo de configuración ensamblado. Se construye una sola vez, es efectivamente inmutable después de construirse, y no contiene lógica de negocio — solo agregación. Se registra en GetIt como cualquier otro singleton transversal y se consume vía `DependencyProvider` (`getWorkspaceCatalog`), igual que cualquier otra dependencia (§6.3/§6.4) — nunca por constructor.

## 5.4. La carpeta de ensamblaje (`dashboards/` en Workspace)

Contiene funciones (o factories) de nivel superior — una por variante — que construyen una instancia real de un modelo de configuración de `catalog/`, componiendo Controllers/Widgets/Views/Providers que ya existen en sus propios módulos. Ejemplo: `ownerDashboard()` arma un `WorkspaceEnsamblado` completo para la variante "propietario".

Esta es la única porción de Presentation donde está permitido:

- construir directamente `ChangeNotifierProvider`/instancias de Controller (ej. `MapaController(...)`) para pasarlas a `WorkspaceDependencies.construir`;
- importar Views/Widgets de otros módulos para asignarlos a un `screenBuilder`.

Es, en efecto, una raíz de composición — pero acotada a un solo módulo (nunca decide DI global, eso sigue siendo `setup_locator.dart`). El nombre de la carpeta describe qué se está ensamblando (`dashboards/` porque cada variante de Workspace ES un dashboard completo); un futuro módulo de catálogo distinto nombraría su carpeta equivalente de forma igualmente descriptiva, no necesariamente "dashboards".

Reglas:

- una función por variante, con nombre `xxxDashboard()` (o el sufijo equivalente que describa la variante);
- no contiene lógica de negocio, solo composición;
- puede importar cualquier cosa que Presentation ya pueda importar (§12) — Widgets, Controllers, otras Views;
- nunca la consume nadie fuera de `catalog/` (el registro) — Presentation no debe llamar a `ownerDashboard()` directamente saltándose el catálogo.

## 5.5. Qué NO es un módulo de catálogo

- No es una forma de evitar las convenciones de nombres de §13 en el resto del módulo: el Controller/State/Widgets propios del módulo (más allá de lo descrito acá) siguen las reglas normales.
- No autoriza crear carpetas libres en otros módulos "por si acaso". Un módulo que solo tiene una pantalla no califica, sin importar cuánta configuración interna tenga.
- No es un reemplazo de Domain: si una de estas clases empezara a decidir una regla de negocio (ej. "qué variantes puede ver este usuario"), esa decisión sigue siendo de Domain/Policies — `catalog/` solo describe y ensambla, nunca decide quién califica para qué.

---

# 6. Controllers

Un Controller representa el estado y el comportamiento observable de una pantalla. Es, junto con el State, la parte más importante de este documento porque es donde con más frecuencia se filtra lógica que no le pertenece.

## 6.1. Responsabilidad

Un Controller de FleetVision:

- coordina la interacción entre la UI y Domain;
- expone las operaciones que la pantalla necesita ejecutar;
- coordina operaciones de Domain;
- centraliza la transformación/derivación de datos de Presentation (incluida aquella cuyo resultado sea un tipo propio de la librería de renderizado usada por el Widget, no un tipo de Domain), salvo la porción cubierta por la §6.8;
- actualiza el estado exclusivamente mediante `copyWith()`.

Un Controller **nunca** contiene:

- lógica de infraestructura (HTTP, SQLite, Firebase, GetIt directo);
- Widgets ni construcción de UI;
- lógica de negocio (eso pertenece a Domain);
- un segundo estado paralelo al State (§6.2).

Debe:

- extender `StateNotifier<TState>`;
- administrar una única clase State que represente el estado observable de la pantalla;
- mantener el estado completamente inmutable;
- usar Freezed para definir ese State.

```
HomeController
    └── StateNotifier<HomeState>
```

Un Controller **no debe ser** ni comportarse como: Repository, RepositoryImpl, Service, Helper, Util, Bridge, Mailbox, Adapter, Wrapper, Factory, Mapper o EventBus. Si una clase pertenece a alguna de esas categorías, no vive en `controllers/`.

## 6.2. Stateless obligatorio: el State es la única fuente de verdad

Los Controllers de FleetVision son coordinadores completamente **stateless**. No almacenan estado propio bajo ninguna forma: ni listas, ni modelos, ni `bool`, `String`, `Map`, `Set`, variables de selección, índices, cachés, ni ningún otro dato mutable.

Todo lo que pueda cambiar durante la vida de la pantalla — elementos seleccionados, listas cargadas, resultados de búsquedas, mensajes, indicadores de carga, flags de UI, modelos temporales, datos pendientes, información retenida entre pasos de un flujo — pertenece exclusivamente al State.

Un Controller nunca debe mantener un "segundo estado". Si una información puede representarse mediante `copyWith()`, entonces no debe existir como atributo del Controller.

Incorrecto:

```dart
class TrackingController extends StateNotifier<TrackingState>
    with DependencyProvider {
  Device? _deviceSeleccionado;
  List<Device> _devices = [];
  bool _loading = false;
  int _paginaActual = 0;
}
```

Correcto:

```dart
class TrackingState {
  final Device? deviceSeleccionado;
  final List<Device> devices;
  final bool loading;
  final int paginaActual;
}
```

Toda modificación del estado se realiza así:

```dart
state = state.copyWith(...);
```

Nunca modificando variables privadas del Controller.

## 6.3. Dependencias vía `DependencyProvider` y `ControllersProvider`

Los Controllers no declaran dependencias como atributos privados.

Incorrecto:

```dart
final TrackingRepository _repository;
final SessionManager _sessionManager;
final ChatRepository _chatRepository;
```

FleetVision centraliza el acceso a las dependencias en dos mixins, separados por qué tipo de cosa resuelven — nunca por conveniencia de quién los usa:

- **`DependencyProvider`** — Repositories, Services, Managers, Cache, Catalogs (§5.3) y cualquier otro componente transversal de Core. Todo lo que **no** sea un Controller global vive acá.
- **`ControllersProvider`** — exclusivamente los Controllers globales: los que están registrados como Singleton en GetIt porque su ciclo de vida es el de toda la app, no el de una pantalla (el caso opuesto es §6.9, Controllers efímeros/scoped). No contiene ningún otro tipo de dependencia — ni un Repository, ni un Service, ni un Catalog se cuelan acá aunque también vivan en GetIt.

```dart
// DependencyProvider
getTrackingRepository
getAuthenticationRepository
getSessionRepository
getSessionManager
getSessionStorage
getWorkspaceCatalog

// ControllersProvider
getWorkspaceController
getExperienceController
getPhoneTrackingController
```

Un Controller mezcla ambos mixins según lo que necesite (`with DependencyProvider, ControllersProvider`) — no hay jerarquía entre ellos, ni uno depende del otro. Un Controller que solo necesita Repositories no importa `ControllersProvider`, y viceversa.

No se declaran atributos privados únicamente para almacenar una referencia obtenida desde GetIt. Esto mantiene todos los Controllers homogéneos y elimina código repetido.

## 6.4. Único punto de acceso a GetIt

Ningún Controller invoca directamente `GetIt.instance` ni `GetIt.I`. Los únicos dos puntos autorizados para resolver dependencias son `DependencyProvider` y `ControllersProvider` (§6.3).

Si un Controller necesita una dependencia nueva que todavía no tiene getter, **primero** se agrega ese getter en el mixin que corresponda según §6.3 — nunca se resuelve la dependencia por otra vía como atajo. Un Controller global nuevo (registrado como Singleton en GetIt) agrega su getter en `ControllersProvider`; cualquier otra dependencia lo agrega en `DependencyProvider`.

## 6.5. Manejo de errores HTTP: `HttpFailureUnwrap`

Todo Controller que consuma repositorios o casos de uso que puedan devolver un `ErrorHttpManejado` debe mezclar obligatoriamente `HttpFailureUnwrap`:

```dart
class NombreController extends StateNotifier<NombreState>
    with DependencyProvider, HttpFailureUnwrap {
```

Este mixin es el único punto autorizado para interpretar y traducir un `ErrorHttpManejado` (`failureMessage(...)`, `onFailure(...)`, `isSesionInvalida(...)`). El objetivo es centralizar el manejo de errores HTTP para evitar duplicación entre Controllers y garantizar mensajes y comportamientos consistentes en toda la app.

No se reimplementan métodos que traduzcan un `ErrorHttpManejado`.

Incorrecto:

```dart
String _mensajeError(ErrorHttpManejado error) { ... }
```

Correcto:

```dart
failureMessage(error)
```

Cuando exista lógica reutilizable para identificar un tipo específico de error HTTP (por ejemplo, sesión inválida), se usa la que ya provee `HttpFailureUnwrap` — no se reimplementa dentro del Controller. Los Controllers únicamente deciden cómo reaccionar ante el resultado (actualizar el estado, mostrar un diálogo, navegar), nunca cómo interpretar el error.

Beneficios: un único punto de mantenimiento para errores HTTP, mensajes consistentes en toda la aplicación, cero código repetido, Controllers más pequeños y legibles.

## 6.6. Métodos privados

Cada método privado representa una única responsabilidad claramente identificable. Cuando un método comienza a mezclar validaciones, transformación de datos, persistencia, actualización del estado, navegación y diálogos, debe dividirse en métodos privados más pequeños, cada uno con su propia responsabilidad.

Cuando dos o más métodos comparten exactamente la misma lógica de Presentation, esa lógica se extrae a un método privado reutilizable. Ejemplos típicos: mostrar errores, actualizar estado, cerrar diálogos, construir mensajes, interpretar errores HTTP.

## 6.7. Controller de referencia

Un Controller ideal de FleetVision se ve así:

```dart
class AuthController extends StateNotifier<AuthState>
    with DependencyProvider, HttpFailureUnwrap {
  AuthController(super.state);

  Future<void> iniciarSesion() async {
    final resultado = await getAuthenticationRepository.signIn(...);

    resultado.when(...);

    state = state.copyWith(...);
  }
}
```

Es decir: sin variables de instancia, sin dependencias privadas, sin estado mutable, sin cachés locales, sin duplicar información que ya existe en el State — únicamente coordinando el flujo entre la UI y Domain.

## 6.8. Excepción técnica: lógica que no puede vivir en el Controller

Un Controller extiende `StateNotifier<TState>` — es Dart puro, sin ciclo de vida de Widget. Por esta razón técnica, y solo por esta razón, el Controller no puede contener:

- la instancia viva de un controlador de plataforma (p. ej. un controlador de mapa);
- lecturas de `BuildContext` (p. ej. tema o metadatos de pantalla obtenidos a través del árbol de Widgets);
- callbacks de gesto o ciclo de vida del Widget (p. ej. inicio/movimiento/fin de una interacción de cámara, `initState`, `didUpdateWidget`, `dispose`);
- llamadas asíncronas que dependan de esa instancia viva.

Esta es la **única** razón válida para que lógica de Presentation permanezca fuera del Controller. No se invoca esta excepción para conservar código en el Widget por conveniencia o para evitar una refactorización. La contraparte de esta excepción en Widgets está en §9.1.

## 6.9. Controllers efímeros (scoped)

No todo Controller vive durante toda la sesión de la app. Un flujo acotado a un modal o a un asistente (por ejemplo, un selector de contactos o un asistente de configuración dentro de un `AppBottomSheet`) puede tener su propio Controller **efímero**: se crea al abrir el modal y se destruye al cerrarlo, en vez de vivir registrado en GetIt.

Reglas del patrón:

- se instancia con `ChangeNotifierProvider`/`Provider` justo en el `builder` del modal, nunca en `DependencyProvider` ni en GetIt;
- su constructor recibe los datos iniciales que necesita (no los resuelve él mismo desde un Repository global si ya se los puede pasar quien lo crea);
- sigue cumpliendo todas las reglas de esta sección (stateless salvo su State, sin GetIt directo, `HttpFailureUnwrap` si aplica);
- al cerrarse el modal, el Controller se descarta junto con su `Provider` — no se reutiliza ni se cachea entre aperturas.

Este patrón no es una categoría arquitectónica nueva: sigue siendo un Controller común (§6.1–§6.8); lo único distinto es su ciclo de vida y el mecanismo de creación.

---

# 7. State

La carpeta `controllers/state/` únicamente contiene clases State implementadas con Freezed. Ningún otro tipo de clase vive ahí. Vive anidada dentro de `controllers/` (nunca como carpeta hermana, §4) porque solo un Controller administra una clase State — no es un tipo de dato independiente que otra capa del módulo pueda consumir por su cuenta.

## 7.1. Plantilla oficial

```dart
@freezed
class NombreState with _$NombreState {
  const NombreState._();

  const factory NombreState({
    @Default(false) bool isLoading,
  }) = _NombreState;
}
```

## 7.2. Reglas obligatorias

Todo State debe:

- declararse mediante `@freezed`;
- usar `with _$NombreState`;
- declarar el constructor privado `const NombreState._();`;
- declarar un `const factory`;
- usar `@Default()` cuando exista un valor por defecto;
- ser completamente inmutable — toda modificación ocurre vía `copyWith()`;
- representar únicamente el estado de la UI.

Un State no debe:

- contener lógica de negocio;
- acceder a infraestructura, Repositories o Services;
- realizar llamadas HTTP ni ninguna operación asíncrona.

## 7.3. Getters derivados

Un State puede exponer getters derivados siempre que:

- se calculen únicamente a partir del propio State;
- no modifiquen el estado;
- no accedan a infraestructura;
- no realicen operaciones asíncronas;
- no contengan reglas de negocio de Domain.

Estos getters existen únicamente para simplificar la construcción de la UI:

```dart
DeviceStatus? get seleccionado => ...
```

## 7.4. Documentación

Toda clase pública se documenta con comentarios `///`. Las decisiones arquitectónicas o reglas de Presentation que no sean evidentes se documentan con comentarios descriptivos, de forma que cualquier desarrollador entienda la intención del código sin inspeccionar otras clases.

## 7.5. Convención de archivos

Todo archivo de State termina obligatoriamente en `_state.dart`:

```
mapa_state.dart
login_state.dart
tracking_state.dart
```

---

# 8. Pages

La carpeta `pages/` contiene las pantallas principales del módulo. Las Pages deben ser **extremadamente pequeñas**.

Una Page nunca debe convertirse en el lugar donde vive la UI de la pantalla. Su responsabilidad es únicamente ensamblar la pantalla conectando Widgets.

Su responsabilidad se limita a:

- obtener el Controller (vía Provider);
- observar el State;
- conectar Widgets;
- definir la estructura general de la pantalla.

Una Page no contiene lógica de negocio, no transforma datos, no decide reglas — solo ensambla. No debe convertirse en un archivo enorme: si empieza a crecer, esa lógica casi siempre pertenece a un Widget nuevo o al Controller, no a la Page.

## 8.1. Convención de archivos

Todo archivo que represente la vista principal de una pantalla termina obligatoriamente en `_view.dart`.

Correcto: `mapa_view.dart`, `login_view.dart`, `tracking_view.dart`, `settings_view.dart`.

Incorrecto: `mapa.dart`, `login.dart`, `tracking.dart`, `settings.dart`.

El objetivo es identificar de inmediato que el archivo representa la vista principal del módulo. Claude debe respetar esta convención en toda pantalla nueva y proponer el renombrado al detectar archivos existentes que no la cumplan.

---

# 9. Widgets

La carpeta `widgets/` contiene widgets pertenecientes únicamente al módulo. Un Widget tiene una única responsabilidad visual — no existen Widgets de cientos o miles de líneas que mezclen varias.

Los Widgets:

- representan UI;
- reciben información (parámetros del constructor);
- notifican eventos al Controller (callbacks).

Los Widgets no:

- consultan repositorios ni acceden a APIs;
- ejecutan lógica de negocio;
- contienen estado global ni un "segundo estado" de la pantalla.

Antes de crear un Widget nuevo deberán revisarse, en este orden:

Design System.
Widgets globales.
Widgets del módulo.

Solo si ninguno resuelve la necesidad podrá crearse un Widget nuevo.

## 9.1. La misma excepción técnica que en Controllers

La porción de lógica descrita en §6.8 (instancia viva de un controlador de plataforma, lecturas de `BuildContext`, callbacks de gesto/ciclo de vida) es la única que puede vivir en un Widget en lugar de en el Controller. Fuera de esa porción, cualquier transformación de datos que no dependa de `BuildContext` ni de un controlador de plataforma vivo pertenece al Controller, no al Widget.

## 9.2. Extracción de Widgets

Un Widget se divide en Widgets más pequeños cuando exista una responsabilidad visual claramente identificable — la extracción debe representar un componente de UI completo, no únicamente reducir el número de líneas del archivo. No se crean Widgets que solo encapsulen dos o tres líneas sin aportar una responsabilidad visual propia.

Cuando un Widget crece demasiado, su implementación puede dividirse en múltiples archivos dentro de `widgets/`. Estos archivos siguen formando parte del mismo Widget y no representan una nueva categoría arquitectónica; su única finalidad es mejorar la legibilidad. No contienen estado propio persistente, no representan lógica de negocio, no acceden a infraestructura y no se convierten en Controllers ni Services.

### Un archivo, una clase

Un archivo de `widgets/` contiene una única clase Widget — más, si hace falta, algún tipo de datos que solo esa clase consume (ej. `NavTab` junto a `AppBottomNavBar`, ver `navigation/widgets/`). Si al construir un Widget aparece una segunda responsabilidad visual con nombre propio (un ítem de lista, un resaltado, un separador), esa responsabilidad se extrae a su propio archivo dentro de `widgets/` — nunca se acumulan varias clases Widget en el mismo archivo, aunque sean privadas y pequeñas. El criterio del párrafo anterior sigue aplicando sin excepción: se extrae porque ya son dos componentes distintos conviviendo en el mismo archivo, no para bajar el conteo de líneas de uno solo.

Consecuencia técnica de mover una clase privada (`_NombreWidget`) a su propio archivo: deja de poder ser privada, porque Dart resuelve `_` por archivo, no por carpeta ni por módulo. Al extraerla se renombra sin el guion bajo (`NombreWidget`) y se documenta con un comentario explícito de que sigue siendo un detalle interno de quien la usa, no un componente pensado para reutilizarse fuera de ahí — salvo que califique para la regla siguiente.

**Antes de dejarla como pieza interna del módulo, se evalúa si en cambio debe subir a un widget global reutilizable** — mismo criterio de prioridad de §10.1. Si la pieza extraída no depende de ningún dato ni lógica específica del módulo (recibe todo por parámetros, igual que cualquier Widget del Design System), es candidata a vivir en `presentation/global/widgets/` en lugar de en `modules/nombre_modulo/widgets/`, para que cualquier otro módulo pueda reutilizarla sin duplicarla (§9.3/§10.2). Esa carpeta se crea recién cuando exista el primer candidato real que la necesite — no antes, mismo criterio de §2 (no generalizar por si acaso). Si en cambio depende de datos o de una decisión propia del módulo (como `NavTab`), se queda local — quedarse local es la opción por defecto; subir a global es la excepción que hay que justificar.

## 9.3. Reutilización antes que creación

Antes de crear un Widget nuevo se verifica si ya existe uno equivalente, propio del módulo o del Design System (§10). Si existe, se reutiliza. No se mantienen múltiples implementaciones del mismo componente visual dentro de la app.

## 9.4. Convención de archivos

Todo archivo que contenga un Widget de Flutter termina obligatoriamente en `_widget.dart`. Esto aplica a cualquier Widget del módulo, incluyendo: Widgets reutilizables, Widgets privados, cards, bottom sheets, dialogs, overlays, bubbles, barras superiores, indicadores, selectores y componentes visuales en general.

Correcto:

```
mapa_view_widget.dart
device_selector_widget.dart
device_bottom_card_widget.dart
device_share_sheet_widget.dart
location_broadcast_indicator_widget.dart
map_marker_info_card_widget.dart
map_marker_info_bubble_widget.dart
mapa_top_bar_widget.dart
phone_broadcast_overlay_widget.dart
```

Incorrecto:

```
device_selector.dart
device_bottom_card.dart
device_share_sheet.dart
location_broadcast_indicator.dart
map_marker_info_card.dart
map_marker_info_bubble.dart
mapa_top_bar.dart
phone_broadcast_overlay.dart
```

El objetivo es que cualquier desarrollador identifique de inmediato que un archivo contiene un Widget con solo observar su nombre. Claude debe respetar esta convención en todo Widget nuevo y proponer el renombrado al detectar Widgets existentes que no la cumplan.

## 9.5. Layouts completos por ScreenClass

> **Convención oficial de arquitectura, para toda la app.** Lo que sigue en esta sección no es una regla exclusiva del módulo `login/` ni una excepción puntual — es la forma oficial en la que **cualquier módulo de SAMVision** debe resolver una pantalla que necesite experiencias estructuralmente distintas según `ScreenClass`. `login/` es hoy el primer caso real donde se aplicó (`CompactLoginLayout`/`DesktopLoginLayout`), no el único lugar donde puede aplicarse. Ningún módulo necesita adoptar `layouts/` hoy solo porque esta convención exista — se adopta cuando ese módulo puntual desarrolle la necesidad real descrita al final de esta sección, exactamente con esta misma estructura de carpetas (ver también el árbol general en §4), para que toda la aplicación crezca de forma consistente en vez de que cada módulo invente su propio criterio.

Un **Layout** es un tipo particular de Widget cuya única responsabilidad es componer la estructura visual COMPLETA de una pantalla (o de una rama de ella) para una o más `ScreenClass` — a diferencia de un Widget normal de `widgets/`, que representa un componente reutilizable dentro de una composición ya armada por otro.

Un módulo crea Layouts únicamente cuando una pantalla necesita árboles de Widgets **estructuralmente distintos** según `ScreenClass` — nunca para variar tamaños o espaciados (eso lo resuelve la Capa 3 de la infraestructura responsiva, §10.4, dentro de un único Widget). Ejemplo real: `CompactLoginLayout` (formulario centrado, `phone`/`tablet`) y `DesktopLoginLayout` (panel de marca + columna de formulario de ancho fijo, `desktop`) en `login/`.

Segundo caso real, de mayor escala: `AppNavigationShell` (`presentation/modules/navigation/`) aplica exactamente este mismo patrón para decidir entre Drawer+BottomNavigation (`CompactNavigationLayout`) y Sidebar (`DesktopNavigationLayout`) — no para una pantalla puntual, sino para la navegación completa de la app. Ver [`NAVIGATION_ARCHITECTURE.md`](NAVIGATION_ARCHITECTURE.md).

Tercer caso real: `MapaView` (`presentation/modules/mapa/`) decide entre `CompactMapLayout` (panel de dispositivos arrastrable sobre el mapa, mecanismo táctil) y `DesktopMapLayout` (paneles fijos de dispositivos/detalle a los costados del mapa, aprovechando el espacio horizontal disponible) — mismo patrón, aplicado al módulo más grande de la app. Ver [`MAP_ARCHITECTURE.md`](MAP_ARCHITECTURE.md).

**Dónde viven.** Dentro de `widgets/layouts/<experiencia>/<archivo>_layout.dart` — una subcarpeta de `widgets/` (nunca un nivel nuevo fuera de `modules/nombre_modulo/`), porque un Layout sigue siendo un Widget del módulo (§4); `layouts/` solo separa "composiciones completas de pantalla" de "componentes reutilizables" dentro del mismo `widgets/`, para que cualquier desarrollador identifique de inmediato cuáles archivos arman una pantalla entera con solo mirar la estructura de carpetas.

**Nombrado de la carpeta de experiencia — nunca por dispositivo.** El nombre describe la EXPERIENCIA de layout (`compact/`, `desktop/`), nunca una plataforma o un dispositivo (`mobile/`, `tablet/`, `web/`, `windows/`, `mac/` están prohibidos). Un Layout `compact` es igual de válido en un Android, un iPhone, una tablet chica, una ventana Desktop achicada por debajo del breakpoint o una ventana Web achicada — nombrarlo por plataforma sería falso y, peor, quedaría obsoleto en cuanto el mismo Layout se reutilice en una plataforma distinta. Un Layout `desktop`, del mismo modo, representa una experiencia pensada para pantallas amplias — es igual de válido si esa pantalla amplia corre en Windows, macOS, Linux o un navegador con la ventana maximizada; la arquitectura sigue basada únicamente en `ScreenClass`, nunca en `kIsWeb`/`Platform.isX` (§10.4).

**Convención de archivos y clases.** Sufijo obligatorio `_layout.dart` (nunca `_widget.dart` — distingue a simple vista "esto arma una pantalla entera" de "esto es una pieza reutilizable"). Clase en PascalCase sin guión bajo (`CompactLoginLayout`, `DesktopLoginLayout`): a diferencia de los objetos de métricas privados de §10.4, un Layout SÍ se instancia desde otro archivo (la Page/View que decide cuál montar), así que no puede ser privado del archivo.

**Quién decide cuál montar.** Únicamente la Page/View del módulo, con un `switch` sobre `screenClass` — nunca `kIsWeb`/`Platform.isX` (§10.4). La Page/View no contiene composición visual propia una vez que existen Layouts para esa pantalla: su única responsabilidad ahí es la decisión.

```dart
Widget _pantallaFormulario(AuthController auth) {
  return switch (context.screenClass) {
    ScreenClass.phone || ScreenClass.tablet => CompactLoginLayout(...),
    ScreenClass.desktop => DesktopLoginLayout(...),
  };
}
```

**Cada Layout resuelve su propia responsividad internamente.** Si un Layout necesita valores fluidos (ej. `CompactLoginLayout` en `phone`), arma su propio `LayoutBuilder` y su propio objeto de métricas privado (§10.4) — nunca recibe esos valores ya calculados desde la Page/View. Esto mantiene cada Layout autocontenido y evita que la Page/View acumule lógica de composición que ya no le pertenece.

**No se crean Layouts sin necesidad real.** Una pantalla que no tiene una diferencia estructural real entre `ScreenClass` no necesita `layouts/` — sigue siendo un único Widget, dimensionado con la Capa 3 de §10.4 (mismo criterio de §2: no se generaliza por si acaso).

---

# 10. Design System y reutilización

FleetVision mantiene un Design System compartido (`presentation/global/widgets/design/`) con componentes reutilizables para toda la app: botones (`AppPrimaryButton`), diálogos (`AppNoticeDialog`, `AppStatusDialog`), bottom sheets (`AppBottomSheet`), tarjetas y superficies (`GlassCard`, `GlassContainer`, `AppCardSection`, `AppSelectableTile`), campos, indicadores y otros componentes visuales de uso transversal.

## 10.1. Prioridad obligatoria del Design System

Este es uno de los principios fundamentales de la arquitectura visual de FleetVision. Antes de crear cualquier Widget nuevo, debe seguirse obligatoriamente el siguiente orden de búsqueda:

1. Verificar si el componente ya existe en el Design System.
2. Verificar si existe un Widget global reutilizable (compartido entre módulos, aunque no viva en `design/`).
3. Verificar si ya existe un Widget equivalente dentro del propio módulo.
4. Solo si ninguna de las opciones anteriores resuelve la necesidad, puede crearse un Widget nuevo.

Esta regla aplica especialmente a componentes como `AppBottomSheet`, `AppNoticeDialog`, `AppPrimaryButton`, `AppSelectableTile`, `GlassCard` y `GlassContainer`. Estos componentes forman parte de la identidad visual de FleetVision y deben considerarse el punto de partida obligatorio para cualquier interfaz nueva.

No se crean variantes locales de estos componentes únicamente por conveniencia o para evitar reutilizarlos. Si un componente existente necesita una capacidad adicional, primero se evalúa si puede extenderse o mejorarse para beneficiar a toda la aplicación, en lugar de duplicarlo dentro de un módulo.

El objetivo de esta prioridad es mantener:

- una experiencia visual consistente (mismo padding, mismas animaciones, mismos diálogos, mismos botones, mismas tarjetas);
- el mismo comportamiento en toda la aplicación;
- un único lenguaje de diseño;
- menor duplicación de código;
- menor costo de mantenimiento;
- una evolución centralizada del Design System.

**La reutilización siempre tiene prioridad sobre la creación de nuevos componentes. Crear un Widget nuevo debe ser la última opción, no la primera.**

## 10.2. Reglas generales

- **Un Widget específico de módulo solo se crea cuando existe una necesidad real** que el Design System no cubre — no como atajo para evitar entender el componente global existente.
- **Ciertos componentes son el único punto de entrada autorizado para su categoría de UI.** Por ejemplo, `AppBottomSheet` es el único punto de entrada para cualquier modal de la app (nunca `showDialog`/`Dialog` centrado), de forma que todo modal comparta el mismo gesto de descarte, la misma animación y el mismo lenguaje visual.

Si una necesidad se repite en dos o más módulos, esa es la señal de que el componente debe subir al Design System en lugar de duplicarse.

## 10.3. Extensiones de contexto (`presentation/extensiones/`)

Presentation mantiene una carpeta adicional, fuera de `modules/` y de `global/widgets/design/`, para extensiones sobre tipos de Flutter que no representan Widgets ni Controllers: `presentation/extensiones/`. Hoy contiene:

- **`BuildContextExtension`** (sobre `BuildContext`) — accesos derivados de `MediaQuery` (tamaño de pantalla, porcentajes de espacio disponible, clasificación de pantalla — ver §10.4).
- **`BoxConstraintsExtension`** (sobre `BoxConstraints`) — el mismo tipo de acceso, pero resuelto contra los `constraints` de un `LayoutBuilder` en vez del ancho completo de la pantalla — necesario cuando el Widget no ocupa toda la pantalla (un modal, una tarjeta, un panel).

Reglas:

- Una extensión de esta carpeta no contiene lógica de negocio, no accede a Repositories/Services/GetIt, y no construye Widgets — únicamente deriva valores a partir del tipo que extiende.
- Antes de crear una extensión nueva se verifica si `BuildContextExtension`/`BoxConstraintsExtension` ya resuelven la necesidad — se extienden, no se duplican (mismo criterio de reutilización de §10.1).
- Todo archivo de esta carpeta termina en `_extension.dart`.

## 10.4. Infraestructura responsiva

El sistema visual de SAMVision resuelve "qué tan grande es la pantalla disponible" con una única fuente de verdad — para que ninguna pantalla necesite comparar anchos a mano (`MediaQuery.of(context).size.width > 600`) ni saber cómo se calcula un breakpoint. Es la forma oficial de construir interfaces adaptativas en SAMVision; se divide en tres capas, cada una con una única responsabilidad:

1. **Clasificación pura.** `ScreenBreakpoints` y `ScreenClass` (`core/theme/screen_breakpoints.dart`, `core/theme/screen_class.dart`). Misma naturaleza que `AppColors`/`AppTextStyles`/`AppDimensions`: tokens estáticos del sistema visual, sin Flutter Widget, sin `BuildContext`, sin estado — por eso viven junto a esos tres en `core/theme/`, y no en una carpeta `core/responsive/` propia (crear una carpeta de primer nivel en Core para un enum y unas constantes sería sobreingeniería mientras no exista una necesidad real que la justifique). `ScreenClass.of(ancho)` es el único lugar que conoce los umbrales de `ScreenBreakpoints`.
2. **Resolución contra el árbol de widgets real.** `BuildContextExtension.screenClass`/`.isPhone`/`.isTablet`/`.isDesktop` (a partir de `MediaQuery`) y `BoxConstraintsExtension.screenClass`/`.isPhone`/`.isTablet`/`.isDesktop` (a partir de los `constraints` de un `LayoutBuilder`) — ver §10.3. Son los ÚNICOS dos puntos autorizados para obtener un `ScreenClass`.
3. **Valores adaptativos del Design System.** El tamaño/espaciado/layout concreto que corresponde a cada `ScreenClass` (ej. un ancho máximo de tarjeta en tablet). Vive junto al token que extiende (`AppDimensions`) cuando se reutiliza en dos o más módulos, o como cálculo privado del propio Widget cuando es un caso puntual — mismo criterio de §10.2 ("si se repite en dos o más módulos, sube al Design System; si no, se queda local").

**Regla de agrupación (Capa 3).** Cuando un Widget necesita **tres o más** valores adaptativos relacionados entre sí (ej. tamaño de logo, tamaño de título, ancho máximo de contenido, espaciado entre secciones), esos valores se agrupan en un **único objeto privado de métricas del propio archivo** — nunca en métodos sueltos del estilo `_logoSize(screenClass)`, `_titleSize(screenClass)`, `_spacing(screenClass)`, uno por valor. La forma preferida es un `record` de Dart (`typedef _XxxMetrics = ({...})`) resuelto por una única función con un único `switch (screenClass)` que arma el record completo por rama — no un `switch` distinto por campo. Ejemplos: `_LoginMetrics` (`login_page.dart`), `_SplashMetrics` (`splash_view.dart`).

Este objeto:

- es privado del archivo que lo consume — nunca se exporta, nunca se importa desde otro módulo;
- no vive en Core ni en el Design System — las métricas pertenecen al Widget que las necesita, no a una infraestructura compartida;
- no es una clase State ni un modelo de Domain — es un value object de solo lectura, construido una vez por `build()`/`LayoutBuilder` y descartado.

Esta regla existe para que un Widget con muchos valores adaptativos relacionados tenga **un único punto de resolución de `ScreenClass`** en vez de N métodos casi idénticos repartidos por el archivo — sin crear una infraestructura compartida tipo "bolsa de métricas" (`ScreenMetrics` global): cada pantalla sigue teniendo sus propias métricas, con sus propios nombres y sus propios valores, exactamente igual que hoy resuelve sus propios `AppDimensions` o su propio `LayoutBuilder`. Un Widget con uno o dos valores adaptativos puede seguir resolviéndolos inline, sin necesidad de este objeto — la regla aplica a partir de tres valores relacionados, no antes.

Regla obligatoria: ninguna pantalla, Widget o Controller compara un ancho/alto contra un número a mano ni importa `ScreenBreakpoints` directamente. Siempre se consulta `context.screenClass` (o `constraints.screenClass` dentro de un `LayoutBuilder`) — esto es lo que permite que los breakpoints o el criterio de clasificación cambien en el futuro (ej. sumar orientación, densidad de píxeles o una categoría nueva) sin modificar ninguna pantalla existente.

Nombrado deliberado: esta familia se llama `Screen*`, nunca `Device*`. En SAMVision "Device" ya es el sustantivo del dominio (un GPS tracker o un teléfono rastreado, ver `domain/models/tracking/`) — reutilizar esa palabra para "tamaño de pantalla" generaría ambigüedad constante entre ambos conceptos.

Componentes existentes que todavía calculan tamaños a mano dentro de su propio `LayoutBuilder` (ej. `TrustedDeviceCard`) son candidatos a migrar a esta infraestructura — no de forma inmediata ni obligatoria en un único cambio, sino progresivamente, cada vez que se vuelva a tocar esa pantalla. No deben coexistir indefinidamente dos formas distintas de resolver el mismo problema.

## 10.5. `ClientCapabilities` vs. `ScreenClass`: dos preguntas distintas, dos mecanismos distintos

Además de "cuánto espacio tengo" (§10.4), Presentation necesita responder una pregunta de naturaleza distinta: "¿puede este cliente hacer X?" — una capacidad **funcional** de la plataforma (¿existe Google Sign-In acá?, ¿puede rastrear ubicación en segundo plano?, ¿debe registrarse como `Device` ante el backend?), no una cuestión de espacio disponible. Ambas preguntas se resuelven con mecanismos distintos, deliberadamente separados, y no deben mezclarse:

- **`ScreenClass`** (§10.4) responde únicamente "cuánto espacio tengo" — nunca decide si una funcionalidad existe.
- **`ClientKind`/`ClientCapabilities`** (`core/platform/client_kind.dart`, `core/platform/client_capabilities.dart`) responden únicamente "qué puede hacer esta plataforma" — nunca deciden cuánto espacio hay ni qué árbol de Widgets montar.

`ClientKind` clasifica el proceso actual una sola vez por ejecución (`telefono` / `navegador` / `escritorio`), vía `kIsWeb`/`defaultTargetPlatform` — nunca `dart:io Platform`, que no compila en Web. `ClientCapabilities` expone esa clasificación por NOMBRE de capacidad (`puedeRastrearEnSegundoPlano`, `debeRegistrarseComoDispositivo`, `puedeAbrirAjustesDelSistema`, `puedeUsarGoogleSignIn`) — el resto de la app nunca compara `ClientKind` crudo fuera de esa clase, mismo criterio que `BuildContextExtension` sobre `ScreenClass` (§10.4, Capa 2).

**Regla obligatoria.** Ningún Layout (§9.5), Widget o Controller decide una capacidad funcional a partir de `ScreenClass`/de qué Layout se montó, ni consulta `Platform`/`kIsWeb`/`defaultTargetPlatform` directamente — eso pasa siempre por `ClientCapabilities`, cuyo único punto de resolución de plataforma es `ClientKind` (dentro de `core/platform/`). En sentido inverso, `ClientCapabilities` nunca decide tamaños, espaciados ni qué árbol de Widgets corresponde — eso sigue siendo exclusivo de `ScreenClass`/Layout. Son ejes ortogonales a propósito y no se combinan en un único objeto: un `ClientKind.navegador` con la ventana angosta sigue siendo `ScreenClass.phone`, y un `ClientKind.escritorio` con la ventana achicada por debajo del breakpoint sigue siendo `ScreenClass.phone`/`.tablet` — cada eje se consulta por separado, donde corresponda.

**Caso de referencia (ya implementado).** Mostrar u ocultar `SocialLoginSection` (Google/Facebook) en el formulario de login es una capacidad funcional, no una decisión de layout — `LoginFormCard` la resuelve consultando `ClientCapabilities.puedeUsarGoogleSignIn` directamente en su propio `build()`, sin que ningún Layout (`CompactLoginLayout`/`DesktopLoginLayout`) participe ni le pase un parámetro para forzarla. Antes de esta regla, la misma decisión se resolvía según qué Layout montaba `LoginFormCard` (`DesktopLoginLayout` pasaba un parámetro para ocultarla) — una capacidad funcional (¿existe Google Sign-In en esta plataforma?) quedaba atada, sin querer, al eje de `ScreenClass` (¿qué tan ancha es la ventana?). Síntoma real que causaba: una ventana Web ancha ocultaba Google Sign-In igual que Desktop nativo (aunque Web sí lo soporta), y una ventana Desktop nativa angosta lo mostraba (aunque Desktop nativo no lo soporta). `ClientCapabilities.puedeUsarGoogleSignIn` resuelve ambos casos correctamente, sin importar el tamaño de la ventana.

**Segundo caso de referencia.** `AppNavigationShell` decide Drawer-vs-Sidebar únicamente por `ScreenClass` — nunca por `ClientKind`/`ClientCapabilities`, aunque "¿qué mecanismo de navegación uso?" pueda sonar a una pregunta de plataforma. Es, en realidad, una pregunta de espacio disponible (igual criterio que cualquier otro Layout de esta sección): un Desktop nativo con la ventana angosta ve el Drawer, igual que un teléfono. Ver [`NAVIGATION_ARCHITECTURE.md`](NAVIGATION_ARCHITECTURE.md) §5-6 para el razonamiento completo.

---

# 11. Comunicación entre capas

La comunicación dentro de Presentation, y de Presentation hacia el resto de la app, siempre es unidireccional:

```
Widget
   ↓
Controller
   ↓
Repository (Domain)
```

Nunca:

```
Widget → Repository        (se salta el Controller)
Widget → Otro Widget       (los Widgets se comunican a través de su Controller/Page)
```

Todo cambio visual proviene del State — nunca de variables mutables repartidas por la UI.

Incorrecto:

```dart
bool cargando = false;
```

Correcto:

```dart
state.isLoading
```

---

# 12. Dependencias

Presentation puede depender de:

- **Domain** (Repositories, modelos, failures);
- **Core** (infraestructura transversal: `DependencyProvider`, sesión, navegación, etc.).

Presentation nunca depende directamente de:

- Data (`RepositoryImpl`);
- APIs, HTTP, SQLite;
- Firebase SDK u otro SDK de infraestructura (salvo infraestructura ya abstraída por Core).

## 12.1. Infraestructura transversal

Si una clase representa infraestructura que no pertenece a una sola pantalla (EventBus, Mailbox, Navigation, Session, Platform, Dependency Injection), no pertenece a un módulo de Presentation — pertenece a Core.

"Navigation" acá se refiere a infraestructura NO visual (ej. un servicio de routing). No aplica a `presentation/modules/navigation/` — ese módulo es enteramente Widgets (Drawer/Sidebar/BottomNavigation y sus átomos compartidos), y Core no aloja Widgets en esta app. Ver [`NAVIGATION_ARCHITECTURE.md`](NAVIGATION_ARCHITECTURE.md) §12 para el razonamiento completo de esa distinción.

---

# 13. Convenciones de nombres

Las clases y los archivos siguen una convención uniforme y obligatoria. El tipo de componente debe poder identificarse únicamente observando el nombre de la clase o del archivo, sin abrir el contenido.

| Tipo | Clase | Archivo |
|---|---|---|
| Controller | `MapaController` | `mapa_controller.dart` |
| State | `MapaState` | `mapa_state.dart` |
| View (Page) | `MapaView` | `mapa_view.dart` |
| Widget | `MapaTopBar` | `mapa_top_bar_widget.dart` |
| Layout (§9.5) | `CompactLoginLayout` | `compact_login_layout.dart` |
| Repository | `TrackingRepository` | `tracking_repository.dart` |
| RepositoryImpl | `TrackingRepositoryImpl` | `tracking_repository_impl.dart` |
| Modelo de configuración de catálogo (§5.3) | `WorkspaceIdentity` | sin sufijo obligatorio — vive en `catalog/` |
| Función de ensamblaje (§5.4) | — (función de nivel superior) | `xxx_dashboard.dart`, nombre descriptivo de la variante |
| Extensión (§10.3) | `BuildContextExtension` | `build_context_extension.dart` |

Sufijos obligatorios de archivo, sin excepciones:

| Tipo | Sufijo obligatorio |
|---|---|
| Controller | `_controller.dart` |
| State | `_state.dart` |
| View | `_view.dart` |
| Widget | `_widget.dart` |
| Layout | `_layout.dart` |
| Repository | `_repository.dart` |
| RepositoryImpl | `_repository_impl.dart` |
| Extensión | `_extension.dart` |

Los modelos de configuración de catálogo (§5.3) no llevan sufijo obligatorio — se identifican por vivir exclusivamente en `catalog/`, igual criterio que los modelos de Domain (identificados por su carpeta, no por el nombre del archivo).

---

# 14. Checklist antes de crear una nueva clase

Antes de crear cualquier clase nueva en Presentation, responder estas preguntas en orden:

1. **¿Cuál es exactamente su responsabilidad?** Debe poder responderse en una sola oración.
2. **¿Pertenece a Presentation?** Si no representa comportamiento o estado de una pantalla, probablemente no.
3. **¿Pertenece a Core?** Si desacopla módulos, coordina navegación o representa infraestructura compartida, probablemente sí.
4. **¿Pertenece a Domain?** Si representa negocio puro, probablemente sí.
5. **¿Pertenece a Data?** Si accede a persistencia o infraestructura externa, probablemente sí.
6. **¿Existe ya una clase con esa responsabilidad?** Si existe, se reutiliza — no se crea una nueva.
7. **¿El nombre representa correctamente su responsabilidad?** El nombre debe responder qué hace la clase, no cómo lo hace.

Si la respuesta a 2–5 apunta a más de una capa, o a ninguna con claridad, es señal de que la responsabilidad todavía no está bien definida — se resuelve eso primero, no la ubicación del archivo.

---

# 15. Reglas para asistentes de IA

Cualquier asistente de IA (Claude Code, ChatGPT u otro) debe leer este documento completo antes de modificar cualquier módulo de Presentation, y respetar todas las reglas aquí descritas sin excepción.

En concreto:

- Toda propuesta debe respetar este documento. Si una propuesta lo contradice, la IA debe **detenerse, explicar la contradicción y solicitar aprobación antes de implementarla** — nunca decidir unilateralmente.
- No se crean nuevas categorías de clases (más allá de Controller/State/Page/Widget, y de los Modelos de configuración de catálogo/Funciones de ensamblaje descritos en §5 para módulos que califiquen) sin una justificación arquitectónica clara y sin actualizar primero este documento.
- Se respetan obligatoriamente todas las convenciones de nombres de §13. No se crean archivos cuyos nombres las contradigan.
- Si se detectan archivos existentes que no cumplan estas convenciones o estas reglas, se propone su corrección antes de continuar con nuevas implementaciones sobre ese mismo archivo — no se deja como deuda silenciosa.
- Ante cualquier ambigüedad entre "seguir la letra de este documento" y "lo que parece más conveniente para la tarea puntual", gana el documento. La consistencia a largo plazo importa más que la conveniencia de corto plazo.

---

# 16. Principios finales

- Responsabilidad única.
- Bajo acoplamiento, alta cohesión.
- Estados inmutables, con una única fuente de verdad.
- Arquitectura predecible antes que ingeniosa.
- Nombres basados en responsabilidades, no en implementación.
- Convenciones de nombres consistentes, sin excepciones.
- No se crean abstracciones innecesarias.
- La simplicidad tiene prioridad sobre la generalización.
- Se reutiliza antes de crear.
- Toda decisión se toma pensando en sostener esta arquitectura durante muchos años, no solo en resolver la tarea de hoy.
