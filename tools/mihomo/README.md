# mihomo tool

A Deno 2 TypeScript CLI behind the stowed `mihomo-api.sh` proxy helper. It replaces the shell
helper's `yq`-based config rendering with pure, tested TypeScript: the provider-DNS lifting rules,
the config merge and the subcommands are plain functions, and every external command goes through
one injectable seam.

The stowed `mihomo-api.sh` facade forwards `render_config`, `startproxy`, `stopproxy` and
`statusproxy` to this CLI; only `setproxy`/`unsetproxy` stay literal shell. The old `yq` overlay
program has been deleted — `yq` survives only as the oracle for `tests/parity_test.ts`.

## Layout

- `main.ts` — the process entry point: `deno run` hands its arguments to `runCli`.
- `src/cli.ts` — the subcommand table (`render`, `status`, `start`, `stop`) and `runCli`, the only
  place the real environment is read.
- `src/render.ts` — renders the runtime config from the template, providers.yaml and the lifted
  overlay, then gates it on `mihomo -t`.
- `src/status.ts` — the running-proxy checks behind `status`.
- `src/lifecycle.ts` — the `start`/`stop` lifecycle: render and validate, cache sudo, set and reset
  macOS DNS, launch and gate success on the full status suite.
- `src/shims/node_process.ts` — import-map shim that keeps `@eemeli/yaml` permission-free (it reads
  `node:process.env` on every parse).
- `src/yaml.ts` — `@eemeli/yaml` helpers that preserve anchors and `!!merge`.
- `src/config.ts` — `loadSettings(env)`: paths and constants, derived from the environment only.
- `src/report.ts` — stdout/stderr plumbing.
- `src/command.ts` — the `CommandRunner` seam and its real subprocess implementation.
- `src/tweaks.ts` — the provider-DNS lifting rules, provider location and selection.
- `src/merge.ts` — pure plain-JS deep merge plus the document-aware merge into a parsed template.
- `tests/` — the permission-free suite; `fake_command.ts` and `fake_report.ts` are the shared
  scripted `CommandRunner` and recording `Reporter`.
- `tests/parity_test.ts` — differential merge parity against `yq`; reads the live config, so it is
  excluded from the permission-free suite (see below).

## Quality gate

One aggregate task runs format check, lint, typecheck and test:

```sh
deno task check
```

The suite needs no permissions, no network and no sudo; fixtures are synthetic and no test reads the
live config directory. `@eemeli/yaml` is pinned in `deno.json` and the lockfile is committed.

`tests/parity_test.ts` is the exception: it is excluded from `deno task test` because it reads the
real `~/.config/mihomo` and shells out to `yq`. It proves the TypeScript merge produces the same
resolved config as `yq eval-all '... * ...'` over the real template, `providers.yaml` and lifted
`provider-tweaks.yaml`, and reports any divergence as differing paths (never values — the
subscription token must not leak). Run it explicitly:

```sh
# needs the external yq and read access; reports 0 differences on a matching config
deno task parity
```
