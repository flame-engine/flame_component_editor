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
| Repository | `packages/component_repository` | Sealed `Component` model (one subclass per `ComponentType`), shared property models (`ComponentPosition`, `ComponentSize`, `ComponentPaint`), capability interfaces and the `ComponentTree` extension for nested children (including child name validation); list/create/save/delete a project's components (one JSON file each in `<project>/.flame_editor/components/`); `ComponentCodeGenerator` and writing/deleting the generated Dart code (see "Code generation") |
| Bloc + view | `lib/home/` | Landing screen: "Open project" button and recent projects list |
| Bloc + view | `lib/project/` | Project dashboard: lists components, add (name + type dialog → editor), edit, delete (with confirmation; also deletes the generated code), settings icon (opens the settings dialog). Pushed from home with `ProjectPage.route` |
| Bloc + view | `lib/component_editor/` | Component editor, `ComponentEditorPage.route(project, component)`: component tree (left, add/remove children, root selected by default), Flame preview (center), properties panel for the selected node (right; children also get a Name field), save button + Cmd/Ctrl+S (also generates the Dart code), unsaved-changes marker in the title, `PopScope` prompt (cancel / discard / save) when leaving with unsaved changes |
| Bloc + view | `lib/project_settings/` | Project settings dialog, `ProjectSettingsDialog.show(context, project)`: output path for generated Dart code (default `lib/components`, text field + Browse) |

`project_repository` and `component_repository` have no Flutter imports, but
their clients depend on Flutter plugins, so they are tested with
`flutter test` / `flutter_package.yml`.

The macOS app sandbox is **disabled** (both entitlements files) so that plain
folder paths in the recent projects list can be reopened after a restart.

## Component types & shared properties

Many Flame components share properties (every `PositionComponent` has a size,
many components have a paint). Each property is therefore built **once** and
component types only declare which ones they have:

| Piece | Where | Example |
| --- | --- | --- |
| Value object (Equatable, JSON, defaults) | `component_repository/lib/src/models/` | `ComponentPosition`, `ComponentSize`, `ComponentPaint` |
| Capability interface | `component_repository/lib/src/models/component_capabilities.dart` | `PositionedComponent`, `SizedComponent`, `PaintedComponent` |
| Component type | `ComponentType` enum + a subclass in `component.dart`'s library (`part` file) | `RectangleComponent implements PositionedComponent, SizedComponent, PaintedComponent` |
| Bloc event | `lib/component_editor/bloc/` | `ComponentEditorSizeChanged` (edits the selected node if it is a `SizedComponent`) |
| Editor widget (`value` + `onChanged`, bloc-agnostic) | `lib/component_editor/widgets/property_editors/` | `SizeEditor`, `PaintEditor`, built from `NumberField`, `ColorField`, `EnumField` |
| Panel wiring | `lib/component_editor/widgets/properties_panel.dart` | `if (component case SizedComponent c) SizeEditor(...)` |
| Flame mapping | `lib/component_editor/widgets/preview/flame_mapping.dart` | `applyPosition`, `applySize`, `applyPaint`, `buildFlameComponent` |
| Code generation | `component_repository/lib/src/code_generation/` | `ComponentCodeGenerator._flameClass` / `_arguments`, `flameMemberNames` in `dart_names.dart` |

**Adding a component type:** add a `ComponentType` value, a `Component`
subclass implementing the right capabilities (reuse the value objects' JSON;
its private `_fromJson` reads only its own properties, `Component.fromJson`
reads the children for every type), and cases in
`Component.create`/`Component.fromJson`,
`buildFlameComponent`, `ComponentCodeGenerator._flameClass` and
`flameMemberNames` (the public members of its Flame class, which child
getters must not override). The panel, bloc, preview and generated code
pick up its properties automatically.

**Adding a property:** add the value object and capability interface, a bloc
event, an editor widget, a branch in `PropertiesPanel`, in
`applyProperties` and in `ComponentCodeGenerator._arguments` (the generated
code must match the preview), then implement the capability on the types
that have it.

### Component tree

Like in Flame, every `Component` has `children` (stored nested in the same
JSON file). A node is addressed by its **path**, the list of child indices
from the root (`[]` is the root); `ComponentTree` (`nodeAt`, `updateNodeAt`,
`addChildAt`, `removeNodeAt`, `uniqueChildName`) does all the immutable tree
edits. The editor state holds `selectedPath`, and every property event edits
`selectedNode`. New children get a unique default name such as `rectangle1`.

The position is only edited on children (`PropertiesPanel` hides it for the
root, which is placed by whoever uses it). In the preview the root is
centered with a center anchor (its stored position is ignored); children keep Flame's default top left anchor
and are positioned relative to their parent. `ComponentPreviewGame.show`
updates the Flame components in place while the tree shape is unchanged
(`haveSameShape`) and rebuilds them otherwise.

Domain models avoid `dart:ui`: colors are ARGB `int`s and `PaintStyle` mirrors
`PaintingStyle`. Conversion to Flame/Flutter types happens only in
`flame_mapping.dart`. Flame's own `Component`/`RectangleComponent` clash with
the domain names, so import Flame with a prefix
(`import 'package:flame/components.dart' as flame;`).

The preview `GameWidget` is created with `autofocus: false`: a focused
`GameWidget` marks every key event as handled, which would swallow the editor
shortcuts. Widget tests that show the preview can't use `pumpAndSettle` (the
game loop never settles), so use `tester.pumpRouteTransition()` from
`test/helpers`.

### Code generation

Saving a component in the editor also writes its Dart code to
`<project>/<outputPath>/<snake_case name>.generated.dart` (`outputPath` comes from
the project settings, default `lib/components`). There is no separate
"generate" action. `ComponentEditorBloc` composes both repositories: it
saves the JSON with `ComponentRepository.saveComponent`, reads the settings
with `ProjectRepository.getSettings` and calls
`ComponentRepository.writeComponentCode`. If only the code fails, the
component still counts as saved (`codeConflict` / `codeFailure` statuses,
shown as a snackbar). `ProjectBloc` deletes the generated file along with
the component.

`ComponentCodeGenerator` (pure, formatted with `dart_style` at language
version 3.8) generates code for **Flame 2.0.0-dev** (the version the app
itself uses, so the preview matches). When upgrading Flame, refresh the
member lists in `dart_names.dart` (`flameMemberNames`). It generates:

- the root as a public class named in PascalCase after the component,
  with the `$` prefix of generated code (`player_ship` → `$PlayerShip`),
  extending its Flame class (games subclass it:
  `class PlayerShip extends $PlayerShip`), with a
  `{super.position, super.anchor, super.priority}` constructor (the root's
  stored position is ignored, like in the preview);
- **a `final` field (a getter) for every child on the component it is
  inside**, named in camelCase after the child (`left_arm` → `leftArm`),
  added in the constructor body;
- a class `$<Root><Child>` (e.g. `$PlayerShipHead`) for every child that
  has children of its own, so the nested children get getters too
  (`player.head.eye`); leaf children are plain Flame components.

Every generated file starts with `ComponentCodeGenerator.header`. The
repository never overwrites or deletes a file without it
(`GeneratedFileConflictException`), so hand-written code in the output
folder is safe.

Child names are the getter names, so the Name field validates them with
`ComponentTree.validateChildName` (`ChildNameError`): a valid identifier
that isn't a keyword, not a member of the parent's Flame class (`size`,
`position`, `paint`, …), and unique in the tree after camelCase
normalization. Root names are validated on creation: the class name must
be a valid identifier, and no other component may generate the same file.
Thanks to the `$` prefix, generated classes never shadow Flame types.

## Domain sketch (expected, not yet built)

These are **likely** candidates as the editor grows; confirm with the user
before creating them.

| Layer | Candidate | Responsibility |
| --- | --- | --- |
| Repository | `component_repository` (exists) | More component types and properties (position, anchor, angle, children…), undo/redo-friendly immutable models |
| Bloc | `component_tree/`, `canvas/` | Selection, canvas interactions |
| Presentation | same features | Desktop layout: tree panel, Flame canvas preview (`GameWidget`), inspector panel |

The live Flame preview is presentation: the `GameWidget`/`FlameGame` used to
render the component being edited lives in the view layer and is driven by
bloc state; it must not own the source of truth for the component.
