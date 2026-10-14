# CI

GitHub Actions in `.github/workflows/main.yaml`, built on
[Very Good Workflows](https://workflows.vgv.dev) (`@v1`):

| Job | Workflow | What it checks |
| --- | --- | --- |
| `semantic-pull-request` | `semantic_pull_request.yml` | PR title follows Conventional Commits |
| `spell-check` | `spell_check.yml` | cspell over `**/*.md` and `**/*.dart` using `.github/cspell.json` |
| `build` | `flutter_package.yml` | `flutter pub get`, `dart format`, `flutter analyze`, `flutter test --coverage`, **min coverage 50%** |

Notes:

- `run_bloc_lint` is `false` for now because `bloc` isn't a dependency yet.
  Once `bloc_lint` is added, flip it to `true`.
- Spell check: add legitimate project words to the `words` list in
  `.github/cspell.json` instead of rewording code.
- Runners are pinned to `runs_on: ubuntu-24.04` (spell-check, build and any
  package jobs). `semantic_pull_request.yml` has no `runs_on` input and always
  uses `ubuntu-latest`; don't pass the input to it, or the workflow fails.
- Dependabot (`.github/dependabot.yaml`) updates pub and GitHub Actions weekly.

## Adding a package job

When creating `packages/<name>`, add a job (keep `min_coverage: 50`):

```yaml
  <name>:
    uses: VeryGoodOpenSource/very_good_workflows/.github/workflows/dart_package.yml@v1  # or flutter_package.yml
    with:
      working_directory: packages/<name>
      min_coverage: 50
      runs_on: ubuntu-24.04
```

Optionally restrict it with `paths:` filters in a dedicated workflow file
(`.github/workflows/<name>.yaml`) so it only runs when the package changes.
