# mihomo tool

A Deno 2 TypeScript CLI behind the stowed `mihomo-api.sh` proxy helper. It replaces the shell
helper's `yq`-based config rendering with pure, tested TypeScript: the provider-DNS lifting rules
and the config merge are plain functions, and every external command goes through one injectable
seam.

Nothing here is wired into the shell yet; this project currently contains the lifting core, the
merge primitive and the shared foundations (settings, YAML helpers, command runner, reporter).

## Layout

- `src/shims/node_process.ts` — import-map shim that keeps `@eemeli/yaml` permission-free (it reads
  `node:process.env` on every parse).
- `src/yaml.ts` — `@eemeli/yaml` helpers that preserve anchors and `!!merge`.
- `src/config.ts` — `loadSettings(env)`: paths and constants, derived from the environment only.
- `src/report.ts` — stdout/stderr plumbing.
- `src/command.ts` — the `CommandRunner` seam and its `Deno.Command` implementation.
- `src/tweaks.ts` — the provider-DNS lifting rules, provider location and selection.
- `src/merge.ts` — pure plain-JS deep merge.
- `tests/` — the permission-free suite; `fake_command.ts` is the shared scripted `CommandRunner`.

## Quality gate

One aggregate task runs format check, lint, typecheck and test:

```sh
deno task check
```

The suite needs no permissions, no network and no sudo; fixtures are synthetic and no test reads the
live config directory. `@eemeli/yaml` is pinned in `deno.json` and the lockfile is committed.
