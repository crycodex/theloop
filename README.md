# Loop

Loop es una app Flutter para practicar y hacer seguimiento de habilidades de entrevista de trabajo. Usa Firebase (Auth + Firestore) como backend y la API de Gemini (incluyendo Gemini Live) para el análisis de CV, la generación del roadmap y las entrevistas simuladas por voz.

## Funcionalidades principales

- **Autenticación** con Firebase Auth (email/password + Google Sign-In) y verificación de correo.
- **Onboarding** guiado tras el primer login, hasta completar el perfil.
- **Análisis de CV** asistido por IA.
- **Roadmap** de preparación personalizado por objetivo de carrera (startup, big tech, consultoría, banca, product manager), con lecciones y quizzes predefinidos en Firestore (`roadmap_catalog`) y customización por IA. El último paso de cada roadmap es una llamada de entrevista.
- **Loops**: seguimiento de pistas/tracks de práctica.
- **Entrevista en vivo**: llamada simulada por voz contra Gemini Live (captura de mic, streaming de audio, transcripción y reporte final).
- **Recap**: resumen/reporte al finalizar cada entrevista.

## Empezar

### Requisitos

- Flutter SDK (canal estable, ver `environment.sdk` en `pubspec.yaml`).
- Un proyecto de Firebase configurado (`firebase_options.dart` ya está generado en este repo).
- Una API key de Gemini.

### Configuración

```bash
flutter pub get
cp env.example.json env.json   # y completa GEMINI_API_KEY
```

`env.json` está en `.gitignore`; no se commitea. Alternativamente se puede pasar la key en build/run con `--dart-define=GEMINI_API_KEY=...`.

### Ejecutar

```bash
flutter run
```

### Seed del roadmap catalog

Las lecciones/quizzes predefinidos por objetivo de carrera viven en `scripts/roadmap_catalog/*.json` y se cargan a Firestore con:

```bash
node scripts/seed_roadmap_catalog.mjs
```

## Comandos útiles

```bash
flutter analyze                          # lint
flutter test                             # correr todos los tests
flutter test test/widget_test.dart       # correr un test puntual
```

No hay configuración de CI en este repo — `flutter analyze` y `flutter test` son los checks locales a correr antes de dar un cambio por terminado.

## Arquitectura

Estructura feature-first con capas de clean architecture bajo `lib/features/<feature>/` (`domain/`, `data/`, `presentation/`). El detalle completo de la arquitectura, el flujo de arranque, el enrutamiento y las convenciones del proyecto está documentado en [CLAUDE.md](CLAUDE.md).
