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
- Dependabot (`.github/dependabot.yaml`) updates pub and GitHub Actions weekly.

## Adding a package job

When creating `packages/<name>`, add a job (keep `min_coverage: 50`):

```yaml
  <name>:
    uses: VeryGoodOpenSource/very_good_workflows/.github/workflows/dart_package.yml@v1  # or flutter_package.yml
    with:
      working_directory: packages/<name>
      min_coverage: 50
```

Optionally restrict it with `paths:` filters in a dedicated workflow file
(`.github/workflows/<name>.yaml`) so it only runs when the package changes.
