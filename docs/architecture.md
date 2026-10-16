# Architecture

This project follows the
[Very Good Ventures layered architecture](https://engineering.verygood.ventures/architecture/architecture/).

## Layers

Data flows **bottom up**. Each layer has a single responsibility and may only
depend on the layer **directly beneath it**.

```
┌──────────────────────────────┐
│ Presentation (lib/<feature>/view)  Flutter widgets, no business logic
├──────────────────────────────┤
│ Business logic (lib/<feature>/bloc) Blocs/Cubits, no Flutter imports
├──────────────────────────────┤
│ Repository (packages/*_repository) Domain rules, composes data clients
├──────────────────────────────┤
│ Data (packages/*_client / *_api)    Raw I/O: file system, serialization
└──────────────────────────────┘
```

### Data layer — `packages/<name>_client`

- Talks to the outside world: file system, JSON/YAML (de)serialization of
  project files, clipboard, OS dialogs, asset loading, process execution.
- No domain or business logic. Should be reusable in an unrelated project.
- Returns raw/DTO models specific to that source.

### Repository layer — `packages/<domain>_repository`

- One repository per domain. Composes one or more data clients and exposes
  **domain models**.
- Pure Dart: **no Flutter imports**, and **no dependency on other
  repositories**.
- Hides *how* data is fetched/stored. If a data client changes, only its
  repository should change.

### Business logic layer — `lib/<feature>/bloc/`

- Blocs/Cubits that compose repositories and turn user intents into states.
- **No Flutter SDK imports** (no `package:flutter/...`) and **no direct
  dependency on other blocs**. If two blocs need to coordinate, do it through
  a shared repository (e.g. a stream) or from the presentation layer.
- Repositories are injected via the constructor.

### Presentation layer — `lib/<feature>/view/` (+ `widgets/`)

- Widgets only. Reads bloc state and dispatches events — nothing else.
- Never touches a data client or repository method directly (repositories are
  only *provided* via `RepositoryProvider` and passed into blocs).

### Leakage examples (don't)

- A widget reading a file from disk or calling a `*Client`.
- A bloc knowing file paths/formats — that belongs in the repository/client.
- A repository importing `package:flutter/...` or another repository.

## Project structure

```
flame_component_editor/
├── lib/
│   ├── main.dart                     # entry point: builds repositories, runApp(App)
│   ├── app/
│   │   ├── app.dart                  # barrel
│   │   └── view/
│   │       └── app.dart              # MaterialApp, providers, theme
│   └── <feature>/                    # e.g. canvas, component_tree, inspector
│       ├── <feature>.dart            # barrel: exports bloc/ and view/
│       ├── bloc/
│       │   ├── <feature>_bloc.dart
│       │   ├── <feature>_event.dart  # part of <feature>_bloc.dart
│       │   └── <feature>_state.dart  # part of <feature>_bloc.dart
│       ├── view/
│       │   ├── <feature>_page.dart   # provides the bloc
│       │   ├── <feature>_view.dart   # consumes the bloc
│       │   └── view.dart             # barrel
│       └── widgets/                  # feature-private widgets (optional)
│           └── widgets.dart          # barrel
├── packages/
│   ├── <domain>_repository/
│   │   ├── lib/
│   │   │   ├── <domain>_repository.dart   # barrel (public API)
│   │   │   └── src/
│   │   │       ├── models/
│   │   │       │   └── models.dart
│   │   │       └── <domain>_repository.dart
│   │   ├── test/                     # mirrors lib/src
│   │   ├── analysis_options.yaml     # includes very_good_analysis
│   │   └── pubspec.yaml
│   └── <source>_client/
│       └── ...                       # same layout
└── test/                             # mirrors lib/
    ├── helpers/                      # pumpApp and shared test utilities
    ├── app/view/app_test.dart
    └── <feature>/
        ├── bloc/<feature>_bloc_test.dart
        └── view/<feature>_page_test.dart
```

### Page / View split

Each feature's `view/` has a `<Feature>Page` that creates and provides the bloc
(`BlocProvider(create: (context) => FeatureBloc(repository: context.read()))`)
and a `<Feature>View` that only consumes it. Tests of the view can then inject
a mock bloc without touching repositories.

### Adding a package

```sh
very_good create dart_package <name> -o packages   # or create by hand following the layout above
```

Then depend on it from the app with a path dependency:

```yaml
dependencies:
  <name>:
    path: packages/<name>
```

…and add a CI job for it (see [ci.md](ci.md)).

## Existing modules

| Layer | Module | Responsibility |
| --- | --- | --- |
| Data | `packages/key_value_storage_client` | Generic string key-value storage (`shared_preferences`) |
| Data | `packages/file_system_client` | Native directory picker (`file_selector`), directory/file existence, list/read/write/delete files |
| Repository | `packages/project_repository` | `Project` and `ProjectSettings` models; pick/open projects; last 10 recent projects; read/write project settings (`<project>/.flame_editor/settings.json`) and pick a project-relative output folder |
| Repository | `packages/component_repository` | `Component` model; list/create/delete a project's components (one JSON file each in `<project>/.flame_editor/components/`) |
| Bloc + view | `lib/home/` | Landing screen: "Open project" button and recent projects list |
| Bloc + view | `lib/project/` | Project dashboard: lists components, add (name dialog → editor), edit, delete (with confirmation), settings icon (opens the settings dialog). Pushed from home with `ProjectPage.route` |
| View | `lib/component_editor/` | Component editor (placeholder), `ComponentEditorPage.route(project, component)` |
| Bloc + view | `lib/project_settings/` | Project settings dialog, `ProjectSettingsDialog.show(context, project)`: output path for generated Dart code (default `lib/components`, text field + Browse) |

`project_repository` and `component_repository` have no Flutter imports, but
their clients depend on Flutter plugins, so they are tested with
`flutter test` / `flutter_package.yml`.

The macOS app sandbox is **disabled** (both entitlements files) so that plain
folder paths in the recent projects list can be reopened after a restart.

## Domain sketch (expected, not yet built)

These are **likely** candidates as the editor grows; confirm with the user
before creating them.

| Layer | Candidate | Responsibility |
| --- | --- | --- |
| Repository | `component_repository` (exists) | Grow `Component` into full definitions (tree of components, properties), undo/redo-friendly immutable models |
| Bloc | `editor/`, `component_tree/`, `inspector/`, `canvas/` | Selection, editing, property changes, canvas interactions |
| Presentation | same features | Desktop layout: tree panel, Flame canvas preview (`GameWidget`), inspector panel |

The live Flame preview is presentation: the `GameWidget`/`FlameGame` used to
render the component being edited lives in the view layer and is driven by
bloc state; it must not own the source of truth for the component.
