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
  list/add/edit/delete components), and placeholders `component_editor` and
  `project_settings`. Packages: `key_value_storage_client`,
  `file_system_client`, `project_repository`, `component_repository`
  (components stored in `<project>/.flame_editor/components/<name>.json`) —
  see "Existing modules" in [docs/architecture.md](docs/architecture.md).
- `bloc`, `flutter_bloc`, `equatable`, `bloc_test`, `mocktail` and `bloc_lint`
  are dependencies; `flame` is **not yet** — add it when the editor canvas
  needs it.
- Toolchain: Flutter stable 3.47 / Dart 3.13. Dart 3.13 lints prefer the
  `new` constructor syntax (`const new({super.key});`) — `dart fix --apply`
  handles it.

## Commits & PRs

- PR titles (and commits) follow [Conventional Commits](https://www.conventionalcommits.org):
  `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`. CI checks this.
- Keep docs in `docs/` up to date when you change architecture or conventions.
