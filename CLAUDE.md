# Flame Component Editor — Agent Guide

A **Flutter desktop app** (macOS, Windows, Linux) for visually creating
[Flame](https://flame-engine.org) components: users compose and tweak
components on a canvas and the editor produces reusable Flame component
definitions/code.

Read this file first, then the doc relevant to your task:

| Doc | When to read it |
| --- | --- |
| [docs/architecture.md](docs/architecture.md) | Before adding any feature, package, bloc or repository |
| [docs/conventions.md](docs/conventions.md) | Before writing Dart code (naming, barrels, style, lints) |
| [docs/testing.md](docs/testing.md) | Before writing or changing tests |
| [docs/ci.md](docs/ci.md) | When touching `.github/` or when CI fails |

## Golden rules

1. **Follow VGV layered architecture** (data → repository → business logic →
   presentation). A layer only talks to the layer directly beneath it. See
   [docs/architecture.md](docs/architecture.md).
2. **`lib/` holds only presentation + state management** (feature folders with
   `bloc/` and `view/`). Data clients and repositories live in their own
   packages under `packages/`.
3. **State management is `bloc`/`flutter_bloc`.** No `setState` for anything
   beyond purely ephemeral widget state (hover, focus, animation controllers).
4. **Lints are `very_good_analysis`.** Code must pass `flutter analyze` with
   zero issues — never silence a lint project-wide to make it pass.
5. **Every change ships with tests.** CI enforces **≥ 50% line coverage**
   (deliberately lower than VGV's usual 100%). Don't chase 100%, but test
   blocs, repositories and non-trivial widgets.
6. **Desktop only.** Do not add `android/`, `ios/` or `web/` targets unless
   explicitly asked.

## Commands

```sh
flutter pub get                                   # install deps
flutter analyze                                   # must report "No issues found!"
dart format lib test                              # format (CI fails on unformatted code)
flutter test --coverage --test-randomize-ordering-seed random
flutter run -d macos                              # or -d windows / -d linux
```

For a package under `packages/<name>`, run the same commands from inside that
directory (or `very_good test -r` from the root if `very_good_cli` is
installed).

Before finishing a task, run **analyze, format and test** and make sure all
three pass.

## Current state

- Features: `home` (open project + recent projects), `project` (dashboard:
  list/add/edit/delete components; adding asks for a name and a component
  type), `project_settings` (settings dialog: generated code output path,
  stored in `<project>/.flame_editor/settings.json`), `palette` (dialog to
  manage the project's named colors, stored in
  `<project>/.flame_editor/palette.json` and generated as `GamePalette` in
  `palette.generated.dart`; paint colors can be picked from it and their
  generated code references `GamePalette.<name>`; colors in use can't be
  renamed or removed — see "Palette" in
  [docs/architecture.md](docs/architecture.md)) and `component_editor`
  (a top bar below the app bar for project-wide actions — the palette
  button —, component tree on the left to add/remove/select/rename nested children,
  live Flame preview in the center, with a toolbar above it whose toggle
  highlights the selected node with a magenta border, properties of the selected node on the
  right, explicit save with button or Cmd/Ctrl+S, unsaved-changes prompt when
  leaving). **Saving also generates the component's Dart code** in the
  settings' output path, with a getter for every child — see "Code
  generation" in [docs/architecture.md](docs/architecture.md). Packages: `key_value_storage_client`,
  `file_system_client`, `project_repository`, `component_repository`
  (components stored in `<project>/.flame_editor/components/<name>.json`) —
  see "Existing modules" in [docs/architecture.md](docs/architecture.md).
- Component types: `polygon` (a Flame `PolygonComponent`: position, anchor
  and angle — children only —, vertices and paint; no size, which is the
  vertices' bounding box; it starts as a triangle or a square, and its
  vertices are edited in the vertices editor dialog, `lib/vertices_editor/`,
  by dragging, adding from edge midpoints and deleting — see "Polygons" in
  [docs/architecture.md](docs/architecture.md)), `rectangle` (position, anchor and angle — edited only on
  children —, size, and paint with color and fill style), `position` (a plain Flame
  `PositionComponent`: position, anchor and angle — children only — and size; draws nothing
  itself, useful as a container) and `circle` (a Flame `CircleComponent`:
  position, anchor and angle — children only —, radius, and paint; the radius is its own
  `ComponentRadius` property, since Flame circles take a radius, not a
  size). Components can have children
  (see "Component tree" in [docs/architecture.md](docs/architecture.md)). Properties are shared between types through capability interfaces —
  see "Component types & shared properties" in
  [docs/architecture.md](docs/architecture.md) before adding a type or
  property.
- `bloc`, `flutter_bloc`, `equatable`, `flame` (**2.0.0-dev** — the
  generated code targets Flame 2; `flame_test` is on the matching 3.0.0-dev),
  `dart_style` (formats the
  generated code, in `component_repository`), `flex_color_picker`
  (pinned to 3.x: 4.x depends on the standalone `material_ui` package, whose
  `MaterialLocalizations` don't match `flutter/material`), `bloc_test`,
  `flame_test`, `mocktail` and `bloc_lint` are dependencies.
- Toolchain: Flutter stable 3.47 / Dart 3.13. Dart 3.13 lints prefer the
  `new` constructor syntax (`const new({super.key});`) — `dart fix --apply`
  handles it.

## Commits & PRs

- PR titles (and commits) follow [Conventional Commits](https://www.conventionalcommits.org):
  `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`. CI checks this.
- Keep docs in `docs/` up to date when you change architecture or conventions.
