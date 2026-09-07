# FleetVision - Arquitectura de Dominio (Domain)

Este documento define las reglas oficiales para construir y mantener la capa **Domain** de FleetVision.

Es el documento hermano de [`presentation/MODULE_ARCHITECTURE.md`](../presentation/MODULE_ARCHITECTURE.md) y comparte su misma filosofía y nivel de exigencia.

Su objetivo es que cualquier persona (o IA) pueda abrir `domain/` y entender, sin contexto externo, qué reglas de negocio existen y por qué.

Este documento es la fuente oficial de verdad para la arquitectura de la capa Domain.

Ninguna implementación puede contradecir este documento.

Si una necesidad real requiere modificar estas reglas, primero debe actualizarse este documento y, una vez aprobado el cambio, implementarse el código correspondiente.

---

# Filosofía

Domain es el núcleo de FleetVision: las reglas de negocio y los conceptos que existen sin importar si la app corre en Flutter, si el backend usa HTTP o gRPC, o si los datos se guardan en SQLite o en memoria.

Toda clase de Domain debe poder explicarse sin mencionar Flutter, HTTP, Firebase, SQLite, Riverpod, GetIt, ni JSON.

Si para explicar una clase de Domain hace falta nombrar alguna de esas cosas, la clase está mal ubicada.

No se crean abstracciones "por si acaso".

No se crean carpetas nuevas sin una necesidad arquitectónica real.

---

# La regla de dependencia (la más importante de este documento)

**El Dominio no depende hacia afuera. Todo depende del Dominio.**

```
   Presentation          Data
        \                 /
         \               /
          v             v
              Domain
```

- Presentation depende de Domain (y de Core).
- Data depende de Domain (implementa sus contratos, mapea sus entidades).
- Domain no depende de Presentation.
- Domain no depende de Data.
- Domain no depende de Core.

Domain es la única capa que **nadie más debería tener que entender primero** para poder trabajar en otra capa. Si Domain está bien escrito, un desarrollador nuevo puede leer únicamente `domain/` y entender qué hace la app, sin abrir un solo Widget ni una sola llamada HTTP.

## Consecuencia práctica

Domain **nunca** debe importar:

- `package:flutter/*` (ni `material.dart`, ni `foundation.dart`, ni `widgets.dart`)
- `package:dio`, `package:http`, o cualquier cliente HTTP
- `package:firebase_*` o cualquier SDK de infraestructura
- `package:flutter_riverpod` / `StateNotifier` (eso es Presentation)
- `get_it` u otro contenedor de Dependency Injection
- `sqflite` u otra librería de persistencia
- nada bajo `lib/app/data/`
- nada bajo `lib/app/presentation/`
- nada bajo `lib/app/core/` (Core es infraestructura transversal; si Domain necesitara algo de ahí, esa pieza probablemente pertenece a Domain, no a Core)

## Domain puede depender de

- `dart:core`, `dart:async`
- `freezed_annotation` (solo para generar unions/entidades inmutables — el código generado no debe introducir infraestructura)
- `meta` (anotaciones como `@immutable`)

Si una dependencia no está en esa lista, no entra a Domain sin discutirlo primero.

## Violaciones ya detectadas en el código actual

Al auditar `domain/` para escribir este documento aparecieron infracciones reales que deben tratarse como deuda técnica a migrar (no como precedente válido):

- `domain/models/tracking/device_kind.dart` importa `package:flutter/material.dart` (probablemente por `IconData`/`Color`). Estos tipos de UI no deberían vivir en una entidad de Domain — la traducción "concepto de negocio → icono/color" pertenece a Presentation.
- `domain/models/sesion/sesion_persistida.dart` importa un paquete de Firebase.
- **(Resuelto)** `workspace_tab.dart`, `workspace_quick_action.dart`, `workspace_identity.dart`, `workspace_dependencies.dart`, `dashboard_configuration.dart`, `workspace_ensamblado.dart` y `estructura_signals.dart` vivían acá con el mismo problema; se migraron a `presentation/modules/workspace/catalog/` como Modelos de configuración de catálogo (ver `PRESENTATION_ARCHITECTURE.md` §5). `workspace_mode.dart` permanece en Domain — es un enum de negocio genuino, sin tipos de UI.
- **(Resuelto — Fase 2 de `PRESENTATION_MULTIPLATFORM_MIGRATION.md`)** `location_capture_settings.dart` importaba `package:flutter/foundation.dart` por `defaultTargetPlatform` (no por `IconData`/`Color` como se había supuesto originalmente en esta lista) — el método `aLocationSettings()` que decidía la variante de `LocationSettings` según la plataforma se movió por completo a `core/mappers/location_capture_settings_mapper.dart` (extensión sobre `LocationCaptureSettings`, mismo criterio que `GeolocatorPositionMapper`). El modelo de Domain quedó como transportador puro de parámetros, sin conocer la plataforma. Sigue importando `package:geolocator/geolocator.dart` (por el tipo `LocationAccuracy`) — no forma parte de esta resolución, ver la nota de deuda pendiente en `PRESENTATION_MULTIPLATFORM_MIGRATION.md`, Fase 2.

Claude deberá señalar estas violaciones y proponer su migración antes de seguir extendiendo esos archivos, siguiendo el mismo criterio que `PRESENTATION_ARCHITECTURE.md` aplica a las convenciones de nombres.

---

# Estructura oficial de Domain

A diferencia de Presentation (que organiza por módulo primero), Domain organiza **por tipo de componente primero**, y dentro de cada tipo, por módulo cuando aplica:

```
domain/
├── models/
│   └── tracking/
│         device_summary.dart
│         device_position.dart
│         device_member_role.dart
│
├── failures/
│   └── tracking/
│         tracking_failure.dart
│
├── functional/
│     respuesta.dart
│     fecha_utc.dart
│
├── policies/
│     device_state_classifier.dart
│     retry_policy.dart
│
└── repositories/
      tracking_repository.dart
      device_status_repository.dart
```

`policies/` es la única carpeta nueva que introduce este documento respecto al estado actual (ver sección dedicada). El resto formaliza lo que ya existe.

---

## models/

Contiene las entidades de negocio: los conceptos que existen independientemente de cómo se transportan o se guardan.

### Reglas obligatorias

- Implementarse con `@freezed` cuando el modelo tenga más de un campo o deba ser inmutable con `copyWith` (patrón ya usado en `DeviceSummary`, `SessionUser`, etc.). Un modelo trivial (un enum, un value object de un solo campo) puede ser una clase simple o un `enum`.
- Ser completamente inmutable.
- No conocer JSON. Un modelo de Domain **no** declara `fromJson`/`toJson` ni usa `@JsonSerializable`. La conversión desde/hacia el contrato del backend vive en un DTO (`data/dto/<modulo>/`) y se traduce mediante un Mapper (`data/mappers/<modulo>/`).
  - Excepción histórica ya presente en el código (`SessionUser`, `SesionState`, `UserLoguinResponse`, `WorkspaceContext`, etc., que hoy tienen `fromJson`/`toJson` propios): se documenta como deuda técnica. No es la convención a seguir para modelos nuevos. Claude debe proponer, no ejecutar por su cuenta, la migración a DTO+Mapper cuando toque esos archivos.
- No acceder a infraestructura (red, disco, Firebase, plataforma).
- Puede tener **getters derivados** siempre que:
  - se calculen únicamente a partir de sus propios campos;
  - no dependan de la hora del sistema salvo que esa sea justamente la regla de negocio a expresar (ej. `DeviceSummary.reportoRecientemente` usa `DateTime.now()` porque "reportó recientemente" es una regla de negocio real, no un detalle de UI);
  - no realicen operaciones asíncronas;
  - no devuelvan tipos de ninguna librería de UI (`Color`, `IconData`, `Widget`).
- No contener lógica que decida "qué hacer" (eso es una Policy, ver más abajo) — un modelo describe qué **es** algo, no qué hacer al respecto.

### Convención de nombres

El nombre de la clase describe el concepto de negocio (`DeviceSummary`, `TrackingSession`, `EstadoOperativo`), nunca el DTO ni la respuesta HTTP que lo originó.

---

## failures/

Contiene los fallos de negocio de cada módulo — el vocabulario de "qué puede salir mal" expresado en términos que Presentation pueda mostrar sin traducir códigos HTTP.

### Reglas obligatorias

- Un archivo por módulo, dentro de `failures/<modulo>/`.
- Nombre de archivo obligatorio: `_failure.dart`.
- Nombre de clase obligatorio: sufijo `Failure` (`TrackingFailure`, `SessionFailure`).
- Implementarse con `@freezed` como union (`factory NombreFailure.caso() = _Caso`).
- Cada caso debe representar una **razón de negocio**, no un código HTTP suelto. Cuando el origen sea HTTP, el caso puede envolver `ErrorHttpManejado` (patrón ya usado en `TrackingFailure.httpFailure`), pero la traducción de status code → caso de failure ocurre en Data, nunca en Presentation.
- Documentar con `///` cualquier caso cuyo significado no sea obvio (ej. por qué `sinPosicion` cubre tres escenarios distintos de 404).

---

## functional/

Contiene tipos utilitarios puros, sin estado y sin efectos secundarios, que el resto de Domain usa para modelar resultados y transformar datos primitivos (fechas, etc.).

### Reglas obligatorias

- Cero dependencias fuera de Dart puro / Freezed.
- `Respuesta<L, R>` es el tipo oficial de resultado (equivalente a un `Either`): `L` = failure, `R` = éxito. Todo método de un Repository que pueda fallar debe devolver `Respuesta<XxxFailure, T>`, nunca lanzar excepciones de negocio ni devolver `null` para representar un error (el `null` solo es válido cuando el propio dominio lo define explícitamente como "no es un error", como en `TrackingRepository.lastPosition`).
- No agregar un segundo tipo "Either" en paralelo — si `Respuesta` no alcanza para un caso nuevo, se discute extenderla, no se crea otro tipo con el mismo propósito.

---

## policies/ (carpeta nueva)

Contiene **solo contratos** (`abstract class`) y los tipos de negocio puros que esos contratos usan (resultados, decisiones, value objects): clasificadores, calculadoras, decisores expresados como interfaz. Hoy parte de esta lógica ya existe en el código (`DeviceStateClassifier` dentro de `models/tracking/`) pero no tiene una carpeta propia — este documento la formaliza para que sea fácil de encontrar.

### Qué es una Policy

Una clase (o función estática) que responde una pregunta de negocio a partir de datos que ya recibió, sin ir a buscarlos ella misma.

Ejemplo ya existente (`DeviceStateClassifier`): recibe banderas ya calculadas (`esMiTelefono`, `sesionLocalActiva`, etc.) y devuelve un `EstadoOperativo`. No sabe de dónde salieron esos datos ni si se van a volver a consultar.

### Debe

- Ser stateless: sin campos mutables, sin instancias vivas de infraestructura.
- Preferir métodos `static` cuando la regla no varía y no hay estado ni configuración (`DeviceStateClassifier.clasificar(...)`).
- Si la política necesita configuración o distintas implementaciones intercambiables, Domain define **solo el contrato** (`abstract class RetryPolicy`, patrón ya usado en `policies/retry_policy.dart`). La clase que efectivamente decide (`RetryPolicyImpl`, con sus constantes de backoff y su lógica de clasificación) es una **implementación**, y toda implementación de un contrato de Domain vive en Data — sin excepción, sin importar si es "pura" o si toca infraestructura. `RetryPolicyImpl` vive en `data/policies_impl/retry_policy_impl.dart`.
- **Domain nunca contiene una clase `Impl`.** El criterio no es "¿toca red o disco?" sino "¿es un contrato o es una realización concreta de ese contrato?". Si es una realización concreta, es Data (o Core si es infraestructura transversal), aunque no tenga una sola línea de I/O.
- Documentar con `///` el porqué de la regla, especialmente si hay una decisión no obvia (ver el comentario de `RetryPolicy` explicando por qué 401 pausa el worker en vez de reintentar).

### No debe

- Realizar llamadas de red, leer archivos, ni acceder a Firebase/SQLite.
- Depender de un Repository para "ir a buscar" datos — los recibe por parámetro.
- Convertirse en un `UseCase` genérico que solo delega a un Repository sin agregar una regla propia (si no hay una decisión de negocio real, no hace falta la clase; el Controller puede llamar al Repository directamente).

### Convención de nombres

| Rol | Sufijo de clase | Sufijo de archivo |
|---|---|---|
| Clasificador | `Classifier` | `_classifier.dart` |
| Política de decisión | `Policy` | `_policy.dart` |
| Calculadora | `Calculator` | `_calculator.dart` |

`RetryPolicy` (el contrato) vive en `policies/retry_policy.dart` (migrado desde `repositories/retry_policy.dart`). `RetryPolicyImpl` vive en `data/policies_impl/retry_policy_impl.dart` — no en Domain.

Migración pendiente (a proponer, no ejecutar sin acuerdo): mover `DeviceStateClassifier` de `models/tracking/estado_operativo.dart` a `policies/device_state_classifier.dart`.

---

## repositories/ (contratos)

Contiene **únicamente contratos** (`abstract class`) que describen qué puede hacer la app con una fuente de datos, nunca cómo.

### Reglas obligatorias

- Un Repository de Domain es siempre `abstract class` (o `abstract interface class`). La implementación real (`XxxRepositoryImpl`) vive en `data/repositories_impl/`, nunca en `domain/`. Sin excepciones — el mismo criterio aplica a cualquier `Impl`, sea de un Repository o de una Policy (ver `policies/`).
- Nombre de archivo obligatorio: `_repository.dart`. Nombre de clase obligatorio: sufijo `Repository`.
- Toda firma que pueda fallar devuelve `Respuesta<XxxFailure, T>`.
- Ningún método puede recibir ni devolver un DTO, un modelo de HTTP, un `Map<String, dynamic>` crudo, ni una excepción específica de un paquete de infraestructura (`DioException`, `FirebaseException`, etc.). Solo tipos de Domain (`models/`, `functional/`, tipos primitivos de Dart).
- Documentar con `///` cualquier decisión de contrato no obvia (ver ejemplo de `positionId` como clave de idempotencia en `TrackingRepository.reportarUbicacion`).

---

# Qué NO pertenece a Domain

- `StateNotifier`, Controllers, Widgets, `BuildContext` — eso es Presentation.
- DTOs y su serialización JSON — eso es Data (`data/dto/`).
- Mappers Dto ↔ Domain — eso es Data (`data/mappers/`).
- Cualquier clase `Impl` (`RepositoryImpl`, `PolicyImpl`), toque o no infraestructura — eso es Data (`data/repositories_impl/`, `data/policies_impl/`).
- `EventBus`, Navigation, Session activa de la app, Dependency Injection — eso es Core.
- Cualquier tipo de una librería de UI (`Color`, `IconData`, `TextStyle`).

---

# Antes de crear una nueva clase en Domain

Responder siempre estas preguntas:

## 1.
¿Cuál es exactamente la regla de negocio o el concepto que representa? Debe responderse en una sola oración, sin mencionar Flutter, HTTP, Firebase ni JSON.

## 2.
¿Es un dato (Model), un posible fallo (Failure), un resultado genérico (Functional), una decisión/regla (Policy), o un contrato hacia una fuente de datos (Repository)? Debe encajar en una sola categoría.

## 3.
¿Necesita alguna dependencia fuera de `dart:core`, `dart:async`, `freezed_annotation` o `meta`? Si la respuesta es sí, probablemente no pertenece a Domain.

## 4.
¿Ya existe un modelo, failure o policy con esa responsabilidad? Si existe, reutilizarlo o extenderlo en vez de duplicar.

## 5.
¿El nombre representa correctamente su responsabilidad? El nombre debe responder qué es o qué decide, nunca cómo se obtiene el dato ni de qué endpoint viene.

---

# Convenciones de nombres — resumen

| Tipo | Sufijo de clase | Sufijo/carpeta de archivo |
|---|---|---|
| Model | (nombre del concepto) | `models/<modulo>/` |
| Failure | `Failure` | `failures/<modulo>/*_failure.dart` |
| Functional/helper | (descriptivo) | `functional/` |
| Policy / Classifier (contrato) | `Policy` / `Classifier` / `Calculator` | `policies/*_policy.dart` |
| PolicyImpl | `PolicyImpl` | **no vive en Domain** — `data/policies_impl/*_policy_impl.dart` |
| Repository (contrato) | `Repository` | `repositories/*_repository.dart` |
| RepositoryImpl | `RepositoryImpl` | **no vive en Domain** — `data/repositories_impl/*_repository_impl.dart` |

No existen excepciones.

---

# Regla para asistentes de IA

Antes de modificar cualquier archivo de Domain se debe leer este documento.

Toda propuesta debe respetar estas reglas y la dirección de dependencia (Domain no depende de nada; todo depende de Domain).

Si una propuesta contradice este documento, la contradicción debe explicarse y solicitar aprobación antes de implementarla.

Si se detecta un archivo de Domain que importe Flutter, HTTP, Firebase, Riverpod, GetIt o SQLite, o que declare `fromJson`/`toJson` propio, debe señalarse como violación y proponerse su migración antes de continuar extendiéndolo — nunca corregirse en silencio como efecto colateral de otra tarea.

No se crearán nuevas categorías de clases (además de Model, Failure, Functional, Policy, Repository) sin justificación arquitectónica clara y sin actualizar primero este documento.

---

# Principios

- El Dominio no depende hacia afuera; todo depende del Dominio.
- Responsabilidad única.
- Resultados explícitos (`Respuesta<L, R>`), nunca excepciones de negocio ni `null` implícito.
- Estados y entidades inmutables.
- Vocabulario de negocio, no vocabulario de transporte (sin DTOs, sin HTTP, sin JSON).
- Nombres basados en responsabilidades.
- No crear abstracciones innecesarias.
- La simplicidad tiene prioridad sobre la generalización.
