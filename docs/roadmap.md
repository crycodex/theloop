# Roadmap: catálogo de lecciones y progreso

Este documento describe cómo funciona la pestaña Roadmap: el catálogo predefinido en Firestore, las lecciones interactivas con quiz, el paso final de llamada y la derivación del progreso y el nivel del usuario.

---

## Resumen

| Aspecto | Detalle |
|---------|---------|
| **Contenido** | Catálogo predefinido bilingüe (ES/EN) por objetivo de onboarding |
| **Fuente de verdad** | JSONs en `scripts/roadmap_catalog/*.json` |
| **Almacenamiento** | Colección global `roadmap_catalog/{goalId}` en Firestore |
| **Goals con catálogo** | `bigTech`, `consulting`, `banking`, `startup`, `productManager` |
| **Fallback / redefinición** | Si el usuario aún no redefinió su roadmap → catálogo (o vacío si el goal es `custom`); "Redefinir con IA" genera uno personalizado con `RoadmapService` para **cualquier** goal |
| **Progreso** | `users/{uid}/roadmap/progress` → `completedStepIds: string[]` |
| **UI** | Camino serpenteante estilo Duolingo + lección con quiz + llamada final |

---

## Estructura de cada roadmap

Cada goal tiene 5 pasos: los pasos 1–4 son **lecciones** (teoría + quiz) y el paso 5 es una **llamada** (loop de entrevista con IA).

```
roadmap_catalog/{goalId}
├── goalId        string        # coincide con el goal del onboarding
├── target        {es, en}      # nombre corto del objetivo
├── finalGoal     {es, en}      # meta final en una frase
├── updatedAt     string        # lo escribe el seed
└── steps[]                     # exactamente 5
    ├── id        string        # único, p.ej. "bigtech_step2_star"
    ├── type      "lesson" | "call"
    ├── title     {es, en}
    ├── category  {es, en}      # chip: Behavioral, Técnica, Case, ...
    ├── guide     {es, en}      # 1-2 frases de contexto
    ├── tips      {es: [], en: []}
    └── lesson                  # solo en type "lesson"
        ├── sections[]          # 3 tarjetas de teoría
        │   ├── title {es, en}
        │   └── body  {es, en}
        └── quiz[]              # 3 preguntas de opción múltiple
            ├── question     {es, en}
            ├── options      {es: [4], en: [4]}
            ├── correctIndex int
            └── explanation  {es, en}
```

Todos los textos localizados son mapas `{es, en}`. El parsing (`Roadmap.fromCatalogMap` en `lib/features/roadmap/domain/entities/roadmap.dart`) resuelve el idioma activo y cae al otro idioma si falta la traducción.

---

## Flujo de datos

El roadmap **personal** del usuario (`users/{uid}/roadmap/latest`) siempre manda sobre el catálogo: si ya existe (porque el goal es `custom`, o porque el usuario tocó "Redefinir con IA" sobre un roadmap de catálogo), esa es su ruta para siempre. El catálogo global solo se usa como contenido por defecto mientras no exista ese doc personal.

```
RoadmapCubit.load()
  ├── users/{uid}/roadmap/latest existe  ──► ese roadmap (personal)
  │     ├── tiene ids de pasos (redefinido con IA, incluye lesson/quiz)
  │     │     └── estados por completedStepIds (_withCatalogStates)
  │     └── formato viejo sin ids (goal custom generado antes de este cambio)
  │           └── estados derivados del total de ciclos (_withDerivedStates)
  └── si no existe  ──► goal con catálogo → roadmap_catalog/{goalId} (solo lectura)
        │                 └── no hay catálogo para el goal (o es `custom`) → RoadmapEmpty (CTA generar con IA)
        ├── users/{uid}/roadmap/progress      # completedStepIds del usuario
        └── tracks del usuario                # ciclos → paso "call" y nivel
              └── RoadmapLoaded(roadmap con estados, userLevel)
```

### Redefinir con IA (`RoadmapCubit.generate`)

Disponible para **cualquier** goal (antes solo para `custom`) desde el botón "Redefinir con IA" en la cabecera del roadmap. Al confirmar (hay un diálogo de aviso porque resetea el progreso):

1. `RoadmapService.generate()` le pide a Gemini un roadmap de 5 pasos con el mismo formato que el catálogo: los primeros 4 son `lesson` (3 secciones de teoría + 3 preguntas de quiz), el quinto es `call`.
2. `RoadmapRepository.resetProgress()` limpia `completedStepIds` (los ids de los pasos anteriores ya no existen).
3. Se guarda en `users/{uid}/roadmap/latest`, reemplazando el catálogo como fuente para ese usuario de ahí en adelante.

### Estados de los pasos (no se persisten)

Se derivan en `RoadmapCubit._withCatalogStates` para cualquier roadmap con ids de pasos estables (catálogo o uno redefinido con IA):

| Estado | Regla |
|--------|-------|
| `completed` | `id` está en `completedStepIds`, o es el paso `call` y hay ≥1 ciclo de loop completado |
| `current` | primer paso no completado (solo uno a la vez) |
| `locked` | todo lo que sigue al paso actual |

Los roadmaps `custom` generados antes de este cambio (sin ids ni lesson/quiz) siguen usando la regla anterior hasta que el usuario los redefina: el avance se deriva del total de ciclos completados (`_withDerivedStates`).

### Nivel del usuario

`RoadmapLoaded.userLevel` se identifica con la **primera llamada**: es el mayor `latestLevel` entre los tracks con `cyclesCompleted > 0`; `null` si aún no hay ciclos. La cabecera muestra el `LevelCircle` con ese nivel, o "Haz tu primera llamada para conocer tu nivel".

---

## UI

### Pantalla Roadmap (`roadmap_screen.dart`, ruta `/roadmap`)

- **Cabecera**: tarjeta verde con nivel (`LevelCircle`), meta final y progreso "X de 5 pasos".
- **Camino serpenteante** (`_RoadmapPath`): nodos circulares alineados en S (patrón `_serpentine`). Visual por estado:
  - bloqueado: círculo gris con candado;
  - actual: círculo verde con anillo, sombra 3D y globo "EMPEZAR";
  - completado: círculo verde con check y estrella dorada;
  - el paso `call` usa ícono de teléfono.
- Al tocar un nodo se abre un **bottom sheet** con guía, tips y CTA (o el mensaje de bloqueado).

### Lección (`roadmap_lesson_screen.dart`, ruta `/roadmap/lesson/:stepId`)

Flujo en 3 fases dentro de la misma pantalla:

1. **Lectura**: secciones de teoría en tarjetas + tips.
2. **Quiz**: una pregunta a la vez, feedback inmediato (correcto/incorrecto + explicación), barra de progreso.
3. **Cierre**: puntaje y botón "Completar paso" → `RoadmapCubit.completeStep(stepId)` guarda el id en Firestore (arrayUnion) y re-deriva los estados, desbloqueando el siguiente nodo.

El quiz no exige puntaje mínimo: terminarlo completa el paso (las lecciones completadas se pueden repasar sin re-escribir progreso... de hecho repasar sí vuelve a llamar `completeStep`, que es idempotente por `arrayUnion`).

### Paso final (llamada)

El CTA "Practicar en llamada" navega a `/loops` para elegir/crear un trayecto e iniciar el loop de entrevista. El paso se marca completado automáticamente cuando existe al menos un ciclo de loop terminado.

---

## Seguridad (firestore.rules)

```
match /roadmap_catalog/{goalId} {
  allow read: if request.auth != null;   // catálogo global: solo lectura
}
```

El progreso vive bajo `users/{uid}/roadmap/{docId}` (subcolección ya permitida para el dueño). Nadie puede escribir el catálogo desde el cliente; solo el seed con credenciales de admin.

---

## Editar contenido y re-subirlo (seed)

1. Edita el JSON del goal en `scripts/roadmap_catalog/` (mantén ids de steps estables: el progreso de los usuarios referencia esos ids).
2. Sube a Firestore (proyecto `the-loop-d46af`, database id `default`):

```bash
# Opción A: service account key (Firebase Console → Service accounts)
GOOGLE_APPLICATION_CREDENTIALS=/ruta/sa.json node scripts/seed_roadmap_catalog.mjs

# Opción B: gcloud con una cuenta con acceso al proyecto
gcloud auth login  # y luego usar un token de acceso vía REST
```

El seed es idempotente: reemplaza el documento completo de cada goal y valida ids únicos y no vacíos. Reutiliza `firebase-admin` desde `functions/node_modules`.

3. Si cambiaste reglas: `firebase deploy --only firestore:rules --project the-loop-d46af`.

### Agregar un goal nuevo

1. Crear `scripts/roadmap_catalog/<goalId>.json` con la estructura de arriba (el `goalId` debe coincidir con el id usado en onboarding/perfil).
2. Ejecutar el seed.
3. Agregar el label del goal en `AppStrings.goalLabel` si es un goal nuevo de onboarding.

No hace falta tocar código Flutter: el cubit carga cualquier `roadmap_catalog/{goalId}` que exista.

---

## Archivos clave

| Archivo | Rol |
|---------|-----|
| `lib/features/roadmap/domain/entities/roadmap.dart` | Entidades + parsing localizado del catálogo |
| `lib/features/roadmap/domain/repositories/roadmap_repository.dart` | Interfaz (latest, catálogo, progreso) |
| `lib/features/roadmap/data/repositories/firestore_roadmap_repository.dart` | Firestore: catálogo + `completedStepIds` |
| `lib/features/roadmap/data/services/roadmap_service.dart` | Fallback: generación con Gemini (goal custom) |
| `lib/features/roadmap/presentation/cubit/roadmap_cubit.dart` | Carga, derivación de estados, nivel, completeStep |
| `lib/features/roadmap/presentation/roadmap_screen.dart` | Camino serpenteante + bottom sheet |
| `lib/features/roadmap/presentation/roadmap_lesson_screen.dart` | Lección: teoría → quiz → cierre |
| `scripts/roadmap_catalog/*.json` | Fuente de verdad del contenido |
| `scripts/seed_roadmap_catalog.mjs` | Subida del catálogo a Firestore |
| `test/roadmap_catalog_test.dart` | Tests del parsing ES/EN |
