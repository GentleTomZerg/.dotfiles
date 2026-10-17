# mihomo

`~/.config/mihomo` is mihomo's home directory. Three files carry configuration,
by role: one shareable, one yours alone, one rebuilt at every start.

## Files

| path | owner | |
| --- | --- | --- |
| `templates/mihomo.yaml` | committed | shareable defaults — ports, TUN, `dns:`, `proxy-groups`, `rules:`. No secrets. |
| `user/providers.yaml` | **yours, gitignored** | your airports and your personal settings. Every secret lives here. |
| `generated/mihomo-runtime.yaml` | derived | what mihomo is launched with. Rebuilt every start — **edits here are lost.** |
| `generated/template-override.yaml` | derived | the keys lifted out of a subscription; merged last. |

`proxy_providers/` (fetched nodes), `rules/` (fetched rule providers), `ui/` (the
dashboard, downloaded on first start) and `cache.db` (selection and fake-ip state)
belong to mihomo. Leave them alone.

**`user/providers.yaml` holds your subscription URL, which carries a personal token.
Never commit it, screenshot it or paste it into an issue** — it is gitignored for
exactly that reason.

## Commands

`~/.zshrc` sources the helper, so a new zsh has these. In any other shell:
`source ~/.config/mihomo/mihomo-api.sh`.

| command | |
| --- | --- |
| `startproxy` | Render, then start. Asks for sudo. Refuses to start a second mihomo. Returns 0 only when every check has passed. |
| `stopproxy` | Stop mihomo; on macOS, reset system DNS. |
| `statusproxy` | Re-check a live proxy: process, controller, a blocked site through `:7890`, the dashboard, and (macOS) the DNS pointer. Idempotent; non-zero on any failure. |
| `render_config` | Rebuild and validate the runtime config without starting anything. |
| `setproxy` / `unsetproxy` | Export / unset the proxy environment variables **in this shell only**. |

Set these in `mihomo-api.sh` (committed). Only `MIHOMO_HOME` is read from your
environment — export it before sourcing to move the whole config tree.

| variable | default | |
| --- | --- | --- |
| `MIHOMO_HOME` | `~/.config/mihomo` | where every path is rooted |
| `MIHOMO_RETRY_TRIES`, `MIHOMO_RETRY_DELAY` | `10`, `1` | one retry budget, shared by every wait |
| `MIHOMO_PROXY_URL` | `http://127.0.0.1:7890` | what `setproxy` exports |
| `MIHOMO_NETWORK_SERVICE` | `Wi-Fi` | macOS only, and hardcoded — wrong wherever the active service is named otherwise |
| `MIHOMO_DNS_SOURCE` | set at render | `provider` or `fallback` — see DNS |

Dashboard: <http://127.0.0.1:9090/ui/>

## Where a setting goes

Render merges three documents, in order: `templates/mihomo.yaml`, then
`user/providers.yaml`, then the lifted overlay. Later wins.

> **Maps merge key by key. Lists replace wholesale.** Your own `rules:` or
> `nameserver:` does not extend the template's — it replaces it.

| I want to | edit | restart? | |
| --- | --- | --- | --- |
| set or override anything | `user/providers.yaml` | yes | it wins over the template |
| change something shared — port, TUN, `rules:`, groups | `templates/mihomo.yaml` | yes | committed, so it applies on every machine |
| add or change an airport | `user/providers.yaml`, `proxy-providers:` | yes | one block per airport; field guide in the header of `templates/providers.yaml` |
| change which keys are lifted out of a subscription | `templates/template-override.yq` | yes | the rule file; committed |
| change DNS | see below | yes | |
| discard derived state | `rm -rf generated/` | yes | rebuilt on the next start |

## DNS

All DNS goes to the airport's resolver, lifted out of the subscription at render
time — it is the only thing that can answer for its node domains, such as
`8e3f7b290d64.eixcloud.com`. The cost: the airport sees every domain you resolve,
and its resolver going down takes your general DNS down with it.

- **Send some domains elsewhere**: `dns.nameserver-policy` in `user/providers.yaml`. Nothing is lifted over that key.
- **Replace the general resolver**: drop `dns.nameserver` from the lift list in `templates/template-override.yq`, then set it in `user/providers.yaml`.
- **Nothing has been lifted yet**: before the subscription has ever been fetched there is nothing to lift, so the fallback `dns:` block at the end of `user/providers.yaml` answers instead. `startproxy` says so.

## Troubleshooting

| you see | run | then |
| --- | --- | --- |
| `mihomo has already started.` / `mihomo is not running` | `pgrep -x mihomo` | you are out of step with reality: `stopproxy; startproxy`. After a crash macOS DNS may still point at mihomo, which just looks like no DNS: `sudo networksetup -setdnsservers Wi-Fi Empty` |
| `Error: providers file not found at …` | — | `cp templates/providers.yaml user/providers.yaml`, then fill in the URL |
| `Error: rendered config failed 'mihomo -t'; not starting.` | the validator output printed under it | fix the file you just edited; `render_config` re-checks |
| `status: FAIL - API controller not responding` | `curl -fsS 127.0.0.1:9090/version` | `stopproxy; startproxy`; still failing, `render_config` |
| `status: FAIL - blocked site not reachable through …:7890` | `render_config`, then the dashboard at `:9090/ui/` | the nodes are usually at fault, not the proxy — check health and the selected group |
| `status: FAIL - dashboard not served` | `ls ui/` | the `external-ui-url` download failed; delete `ui/` and restart |
| `status: FAIL - system DNS not pointed at 198.18.0.2` | `scutil --dns \| grep 198.18` | wrong `MIHOMO_NETWORK_SERVICE` (hardcoded `Wi-Fi`); fix it and restart |
| `startproxy: note - no provider dns: was available to lift` | — | not a failure; `stopproxy; startproxy` once the subscription has been fetched |
| `startproxy` fails and gives no reason | `lsof -nP -iTCP:7890 -sTCP:LISTEN` | mihomo's launch output is discarded, so a port already in use is silent; free `7890`, or move `mixed-port` and `MIHOMO_PROXY_URL` |
| a tool ignores the proxy | `env \| grep -i proxy` | `setproxy` only affects the shell it ran in — run it there, or rely on TUN |

Never debug by editing `generated/`: `stopproxy; startproxy` rebuilds it from the
two files you own.

## Further reading

- [`README.md`](../../../README.md) §Phase 4 — provisioning a new machine from nothing, with checks.
- `templates/providers.yaml` header — every provider field, and the fallback `dns:` block.
- `templates/template-override.yq` header — which subscription keys are lifted, and which never will be.
- [`docs/research/mihomo-provider-dns.md`](../../../docs/research/mihomo-provider-dns.md) — why the DNS arrangement is this way, and what was tried instead.
