# mihomo

`~/.config/mihomo` is mihomo's home directory. mihomo reads one config file, built
at every start from two files you edit:

| file | |
| --- | --- |
| `templates/mihomo.yaml` | shared defaults — ports, TUN, `dns:`, `proxy-groups`, `rules:`. Committed. |
| `user/providers.yaml` | **yours**, gitignored — your airports and your personal settings. |
| `generated/` | built at every start; edits here are lost. |

`proxy_providers/`, `rules/`, `ui/`, `cache.db` belong to mihomo. Leave them alone.

## How it works

```
templates/mihomo.yaml       shared defaults
user/providers.yaml         your airports + your settings
  ── lifted keys ──         a few keys out of your airport's own config
generated/mihomo-runtime.yaml     ← what mihomo reads
```

Later wins. Maps merge key by key; **lists replace wholesale**, so a `rules:` or
`nameserver:` of your own does not extend the template's, it replaces it.

A subscription is a whole Clash config, but mihomo takes only the node list from it.
The lift list takes back `dns.nameserver`, `dns.fake-ip-filter`, `dns.use-hosts` and
`hosts` on purpose — and those beat your copy of the same key, so to own one, remove
it from the list. Everything else in the subscription (`listen`, `enhanced-mode`,
`fake-ip-range`, `default-nameserver`) is ignored; the template has already decided.
The list is `templates/template-override.yq`. With several airports, only the first
whose cache exists contributes.

## Start, stop, check

```bash
startproxy     # build the config, start mihomo, verify it
stopproxy      # stop
statusproxy    # re-check a running proxy
setproxy       # point this shell at :7890   (unsetproxy to clear)
```

Dashboard: <http://127.0.0.1:9090/ui/>

After editing any config file: `stopproxy` then `startproxy`.

## Add or change an airport

Airports are the `proxy-providers:` blocks in `user/providers.yaml`. On a new
machine, create that file first:

```bash
cp ~/.config/mihomo/templates/providers.yaml ~/.config/mihomo/user/providers.yaml
```

One block per airport:

```yaml
proxy-providers:
  e-ix:
    type: http
    url: "https://your-airport.example/subscribe?token=..."   # your secret
    path: ./proxy_providers/e-ix.yaml    # cache; unique per block
    interval: 86400                      # refresh daily
    header:
      User-Agent: ["Clash-verge/v2.2.0"] # decides the format
    override:                            # per-node rewrites
      additional-prefix: "[e-ix]"
```

- **Second airport** — copy the block, change `name`, `url`, `path`. Its nodes join
  every group by themselves.
- **Rotate a token** — edit `url` in place.
- The `User-Agent` is load-bearing: airports serve a different format per client,
  and only a Clash-family agent returns the full config the lift list reads.
- The `url` carries your personal token. Never commit it or screenshot it.

All fields: header of `templates/providers.yaml`. Then restart.

## Set your own setting

Put any top-level key in `user/providers.yaml`:

```yaml
mixed-port: 7897
sniffer:
  enable: false
```

It overrides the template. Then restart.

## Change the DNS resolver

By default you use the airport's resolver — the only thing that can answer for its
node domains like `8e3f7b290d64.eixcloud.com`, which public resolvers know nothing
about.

**Send some domains elsewhere, keep the rest.** Add a policy to
`user/providers.yaml`. Nothing is lifted over this key, so it just works:

```yaml
dns:
  nameserver-policy:
    "+.corp.example.com": https://10.0.0.1/dns-query
```

**Replace the general resolver.** Two steps, both needed:

1. Remove `dns.nameserver` from the lift list in `templates/template-override.yq`.
   That file is committed, so this decides it for every machine.
2. Set `dns.nameserver` in `user/providers.yaml`. The value stays per-machine.

Then restart.

The airport sees every domain you resolve, and its resolver going down takes your
DNS with it. That is the default's trade.

**On a machine that has never fetched the subscription** there is nothing to lift
yet, so the `dns:` block at the bottom of `user/providers.yaml` is used. `startproxy`
says when that happened:

```
startproxy: note - no provider dns: was available to lift ...
```

Restart once the subscription has been fetched and the airport's resolver takes over.

## Further reading

- [`README.md`](../../../README.md) §Phase 4 — provisioning a new machine, with checks.
- [`docs/research/mihomo-provider-dns.md`](../../../docs/research/mihomo-provider-dns.md)
  — why the DNS arrangement is this way, and what was tried instead.
