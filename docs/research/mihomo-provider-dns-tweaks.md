# mihomo proxy-providers vs. the provider's own config (dns / hosts / proxy-server-nameserver)

**Question.** Clash Verge picks up provider-specific tweaks from the subscription
(`hosts:`, `dns: use-hosts: true`, `dns.nameserver`, `proxy-server-nameserver:`).
The local mihomo setup (`~/.config/mihomo`, rendered by the `mihomo` tool) does not,
and some networks cannot reach the nodes. Why, and how do we get them back?

**Verdict.** mihomo's `proxy-providers` deliberately reads **only the `proxies:`
array** out of the fetched document. Everything else in that document — `dns`,
`hosts`, `proxy-groups`, `rules`, `tun`, `sniffer` — is discarded by the parser.
Clash Verge behaves differently because a Remote profile *is* the whole subscription
document; its Merge/Script layers are applied on top of that document. mihomo has
no equivalent layer: `-f` takes exactly one config file, so any merge must happen
outside the core (which is exactly what the `render` subcommand of the `mihomo`
tool does).

Sources: mihomo `Meta` @ `88dcbf7` (2026-09-30); local binary `Mihomo Meta v1.19.30`.

---

## 1. Why the tweaks are dropped

`adapter/provider/provider.go` defines the schema used to parse a fetched provider
document:

```go
type ProxySchema struct {
	Proxies []map[string]any `yaml:"proxies"`
}
```

`NewProxiesParser` unmarshals the downloaded bytes into that struct, so only
`proxies` is ever looked at; unknown top-level keys are ignored. The provider
*definition* schema (`adapter/provider/parser.go`, `proxyProviderSchema`) has no
`dns`/`hosts` field either — only `filter`, `exclude-*`, `override` (per-node
fields), `health-check`, `header`, `interval`, … So there is no supported way to
make a provider contribute `dns:` or `hosts:`.

Corollary: the same applies to the provider's `proxy-groups` and `rules` — that is
why this repo's groups are written with `include-all: true` instead.

`main.go` reads the config path with `flag.StringVar(&configFile, "f", ...)` — one
file. `hub.Parse` takes a single byte slice. There is no "merge these N configs"
flag in the core.

Clash Verge: a **Remote profile** stores the raw subscription; **Merge** profiles
override top-level keys of that profile and **Script** profiles transform it
(`main(config)`); they run in the order subscription → Merge → Script. Because the
base is the provider's whole document, the provider's `dns:` block is present and
their Merge only has to override what they want.

> Note: the cached provider file (`proxy_providers/e-ix.yaml`) is the raw download.
> It is a full Clash config, so the tweaks are visible there even though mihomo
> ignores them.

---

## 2. What the `e-ix` subscription actually contains

Fetched with `User-Agent: Clash-verge/v2.2.0` (what `providers.yaml` sets), the
subscription is a complete Clash config whose top-level keys are:

```
port socks-port redir-port mixed-port external-controller allow-lan
mode log-level ipv6 dns proxies proxy-groups rules
```

Its `dns:` block (the part that matters here):

```yaml
dns:
  enable: true
  listen: '0.0.0.0:1053'
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  use-hosts: true
  default-nameserver: [119.29.29.29, 223.5.5.5, 114.114.114.114]
  nameserver: ['https://zone.rlose.com:39933/api-query', 'https://radar.rlose.com/api-query']
  fake-ip-filter: [ ...~100 entries: stun, ntp, game consoles, QQ/NetEase music, ... ]
```

Facts worth keeping:

* There is **no `hosts:` map** and **no `proxy-server-nameserver:`** in the current
  subscription (checked against every UA variant the provider serves: `clash`,
  `clash.meta`, `Clash-verge/v2.2.0`, `clash-verge-rev/*`, `Stash`, `ClashX`).
  The provider's tweak *is* `dns.nameserver` — their own resolvers.
* The subscription is **UA-dependent**. `mihomo/1.19.30` gets a ~12 KB plain
  (base64-ish) list; `sing-box/*` gets sing-box JSON; `Shadowrocket` /
  `Quantumult X` get ~11–13 KB. Only the Clash-family UAs get the full config.
  This is why `header.User-Agent` in `providers.yaml` is load-bearing.
* Node `server:` values are **domains** under the provider's private zone, e.g.
  `8e3f7b290d64.eixcloud.com`. They are not in the public DNS:

  | resolver | `8e3f7b290d64.eixcloud.com` A |
  | --- | --- |
  | `https://zone.rlose.com:39933/api-query` (provider) | `128.108.220.144` |
  | `https://radar.rlose.com/api-query` (provider) | `128.108.220.144` |
  | `https://doh.pub/dns-query` | *(no A record)* |
  | `https://dns.alidns.com/dns-query` | *(no A record)* |

  So resolving node domains through the user's own resolvers (`doh.pub`,
  `alidns`) can simply fail — or hand back a stale/parked answer — depending on
  the network. That is the "cannot connect to my nodes in some networks" symptom.
  (Probed from this machine; the provider DoH requests were themselves carried by
  the running mihomo, so treat the exact IPs as illustrative, not as constants.)

---

## 3. How the three mechanisms work

### `hosts:` (top level) + `dns.use-hosts`

`hosts:` is a `/etc/hosts`-style map at the **root** of the config (a sibling of
`dns:`, not inside it). Keys accept the Clash domain wildcards (`*` = one label,
`+`/`.` = any number of labels); values are an IP, a list of IPs, the keyword
`lan`, or a single domain alias. A fully specified name beats a wildcard:
`foo.example.com` > `*.example.com` > `.example.com`.

Two separate consumers:

1. **The DNS server.** `dns/middleware.go` only installs the `withHosts`
   middleware when the enhancer's `useHosts` flag is set
   (`dns/enhancer.go` ← `config.UseHosts` ← `dns.use-hosts`, **default `true`**,
   `config/config.go:508`). So `use-hosts: false` stops mihomo from *answering
   client queries* out of `hosts:`.
2. **mihomo's own resolution.** `component/resolver/resolver.go`
   (`LookupIPv4WithResolver`, `LookupIPv6WithResolver`, `LookupIPWithResolver`)
   consults `resolver.DefaultHosts` **before** touching any resolver and
   **regardless of `use-hosts`**:

   ```go
   if node, ok := DefaultHosts.Search(host, false); ok { ... return node.IPs, nil }
   ```
   `hosts` is always populated (`localhost → 127.0.0.1` is inserted
   unconditionally in `config.parseHosts`), and `hosts:` entries therefore work
   even with `dns.enable: false`. The lookup happens before the dialer picks a
   resolver, so a `hosts:` entry pins a proxy-server domain too — the most
   forceful, most brittle fix.

Caveat found in source: for the *internal* path only IP entries are honoured.
`LookupIPWithResolver` returns `node.IPs`, which is empty for a domain-alias
entry — aliases only work through the DNS-server path.

### `dns.proxy-server-nameserver` (and `-policy`)

The dedicated resolver for the `server:` field of proxies. Default: empty.

Selection happens once, in `hub/executor/executor.go`:

```go
if r.ProxyResolver.Invalid() {            // ProxyResolver exists and has servers
	resolver.ProxyServerHostResolver = r.ProxyResolver
} else {
	resolver.ProxyServerHostResolver = r.Resolver   // fall back to nameserver
}
```

(`(*Resolver).Invalid()` is a misnomer — `dns/resolver.go:386` returns
`len(r.main) > 0`, i.e. "is configured".) `ProxyResolver` is only built when
`proxy-server-nameserver` is non-empty (`dns/resolver.go:607`).

Who uses it: `component/dialer/dialer.go:380`

```go
if preferResolver == nil { preferResolver = resolver.ProxyServerHostResolver }
```

i.e. any dial (the outbound's own socket to the proxy server, and helpers such as
`adapter/outbound/util.go:54`) that doesn't pass an explicit resolver. So
`proxy-server-nameserver` **only** affects how proxy-server hostnames are looked
up; ordinary user traffic keeps using `nameserver`/`fallback`. That is exactly the
knob wanted here: send `*.eixcloud.com` to the provider's resolvers without
routing all DNS through the provider.

`proxy-server-nameserver-policy` is a `nameserver-policy`-shaped map that only
applies to node domains, and only if `proxy-server-nameserver` is non-empty.

The resolver hostnames (`zone.rlose.com`, `radar.rlose.com`) are resolved with
`dns.default-nameserver` (must be bare IPs), so there is no chicken-and-egg.

### `dns.nameserver-policy`

Per-suffix resolver map; higher priority than `nameserver`. `'+.eixcloud.com':
<resolver>` has nearly the same effect as `proxy-server-nameserver` but also
applies to client traffic for that suffix. `proxy-server-nameserver` is the
narrower tool.

### `dns.respect-rules`

Makes DNS *upstream connections* obey the routing rules. mihomo refuses to start
if `respect-rules: true` and `proxy-server-nameserver` is empty
(`config/config.go:1420`). Default `false` = DNS connections go out directly.

---

## 4. Getting the tweaks into this repo's config

The pipeline is "template + untracked provider spec + lifted overlay, deep-merged
into `mihomo_runtime.yaml`". The `mihomo` tool
(`tools/mihomo/src/merge.ts`) performs the merge in-process; it reproduces the
semantics the old `yq` pipeline had, so a key added in `providers.yaml` lands next
to the template's keys:

```bash
# the old pipeline, kept as the differential oracle in tests/parity_test.ts
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1) * select(fileIndex == 2)' \
    mihomo.yaml providers.yaml provider-tweaks.yaml > mihomo_runtime.yaml
```

`yq`'s `*` merges maps recursively and replaces arrays (verified against
`yq v4.54.1`), and the TypeScript merge matches it key for key on the real config.

### Shipped: the fallback in `providers.yaml`

The minimal change that reproduces what Clash Verge gets from the provider's
`dns.nameserver` — without routing general DNS to the provider — is a top-level
`dns:` block in `providers.yaml` (the untracked, per-machine file):

```yaml
dns:
  use-hosts: true            # already the default; keep it explicit
  # Only proxy-server hostnames (*.eixcloud.com) are resolved with these.
  proxy-server-nameserver:
    - https://zone.rlose.com:39933/api-query
    - https://radar.rlose.com/api-query
```

It sits in `providers.yaml` rather than `mihomo.yaml` because the resolver
hostnames are airport-specific and `mihomo.yaml` is the shareable template. Being
fileIndex 1, it covers the window before the subscription has ever been fetched;
`providers.template.yaml` ships it live so a fresh machine only has to fill in the
URL.

### Optional: mirror more of the provider's `dns`

Put the provider's `fake-ip-filter` (NTP, STUN, consoles, music apps) and, if
desired, their `nameserver` in too. Keep the provider's `listen` and
`enhanced-mode` out — the local ones are intentional.

### Optional: pin via `hosts:`

Only if the provider hands the whole zone one stable gateway IP:

```yaml
hosts:
  '+.eixcloud.com': 128.108.220.144
```

Works even with DNS broken (`LookupIP*WithResolver` checks hosts first), but goes
stale if the provider rotates IPs.

### Implemented: auto-extract at render time, providers.yaml as fallback

The `mihomo` tool lifts the provider's resolver list out of the cached provider
file at render time (`tools/mihomo/src/tweaks.ts`), so the `dns:` block in
`providers.yaml` is only the fresh-machine fallback. See the Decision section below.

---

## 5. Things that do **not** work

* `dns:`/`hosts:`/`rules:`/`proxy-groups:` inside a `proxy-providers` entry —
  `proxyProviderSchema` has no such fields, `ProxySchema` reads only `proxies`.
* Passing several `-f` files, or a comma list, to mihomo — one file only.
* `override` / `override-expr` on a provider — they rewrite **node fields**
  (`udp`, `skip-cert-verify`, `servername`, names, …), never the config's DNS.
* `type: inline` with `payload` — the payload is a fallback **proxies list**; it
  is marshalled back into `ProxySchema{Proxies: ...}` before parsing.

---

## 6. Decision (implemented)

Settled by design review; implemented in the `mihomo` tool (`tools/mihomo`):
`src/tweaks.ts` holds the lifting rules, `src/merge.ts` the merge and
`src/render.ts` the pipeline.

**Source of truth — the cached provider document, read at render time.**
`render_config` only runs while mihomo is stopped (`startproxy` bails on
`pgrep -x mihomo`), so a provider refresh cannot race the read, and mihomo's
non-atomic `safeWrite` does not matter. Cache paths come from `providers.yaml`
(`.proxy-providers[].path`), not a glob, so a cache file left behind by a removed
subscription cannot leak in.

**Whitelist** — everything else in the provider's `dns:` is ignored:

| provider key | becomes |
| --- | --- |
| `dns.nameserver` | `dns.proxy-server-nameserver` (node lookups only) |
| `dns.use-hosts` | `dns.use-hosts` |
| `dns.fake-ip-filter` | `dns.fake-ip-filter` |
| `dns.proxy-server-nameserver` | itself, if a provider ships one |
| root `hosts` | root `hosts`, if a provider ships one |

**Deny-list** — `listen`, `enable`, `enhanced-mode`, `fake-ip-range` (lifting
`listen` would open `0.0.0.0:1053`; the rest are idempotent or already decided),
and `default-nameserver` (ours is `tls://`, the provider's is plaintext, and the
key only bootstraps resolving the resolver's own hostname).

Crucially the provider's `nameserver` is mapped to `proxy-server-nameserver` and
**not** to `dns.nameserver`: `doh.pub`/`alidns` stay as the general resolver, so
only node domains go to the provider. That is Clash Verge's *behaviour* without
its *configuration*.

**Circular resolvers are skipped, not copied.** A `#RULES` or `#<proxy>` /
`#<interface>` suffix would make the resolver need the proxy it resolves for.
`#key=value` params (`skip-cert-verify`, `ecs`, …) are kept. Detection: take the
first `#`-segment, split on `&`; skip if it is `RULES` or lacks `=`.

**Fallback + hint.** `providers.yaml` keeps the `zone`/`radar` pair under a
top-level `dns:` key. On a machine with no cache yet, the generated tweaks file is
`{}`, that fallback survives the merge, and `render_config`/`startproxy` print a
warning — an action, not a FAIL. It lives there rather than in `mihomo.yaml`
because `mihomo.yaml` is the *shareable* template (README §provisioning) while the
resolver hostnames are airport-specific, exactly like the subscription URL — and
because a top-level `dns:` key in `providers.yaml` is merged as fileIndex 1, which
covers the pre-fetch window on its own. `providers.template.yaml` ships the block
live so `cp` + fill-the-URL is still a complete fresh-machine config.

**Drift is reported, not silent.** Because the generated file overrides the
fallback, every render prints the resolver list it applied and warns when it
differs from `.dns."proxy-server-nameserver"` in `providers.yaml`.

**Gate scope (`mihomo -t`).** Verified: it rejects invalid YAML, a
`proxy-server-nameserver` that is a scalar rather than a list, and unsupported
proxy types. It does **not** reject an unresolvable resolver hostname — that
still prints `test is successful` and only fails at dial time. The gate is a
structural check, not a reachability check.

**Deferred: multi-provider.** Until designed, more than one provider carrying a
`dns:` block triggers a warning and the first in `providers.yaml` order wins. The
reason the obvious answer (concatenate every provider's resolvers into one
`proxy-server-nameserver`) is wrong: `dns/util.go:batchExchange` fires all
nameservers concurrently and takes the first response that is not an error, and
only `SERVFAIL`/`REFUSED` count as errors — an NXDOMAIN from the wrong provider
earns a "success" and wins the race. The correct mechanism is
`dns.proxy-server-nameserver-policy`, matched before `main`
(`dns/resolver.go` `matchPolicy`), keyed by node zone. The zone must not be
derived by stripping labels off `proxies[].server` — naive eTLD+1 extraction can
collapse `a.foo.com.cn` to `+.com.cn`.

**Files.** `tools/mihomo/src/tweaks.ts` (the lifting rules — read this one
first), `tools/mihomo/src/merge.ts` (the 3-document merge),
`tools/mihomo/src/render.ts` (locating the provider caches, the `-t` gate, the
startproxy nudge), and the thin `mihomo-api.sh` facade that forwards the
subcommands. `providers.template.yaml` carries the `dns:` fallback block plus the
header note; `.gitignore` covers `provider-tweaks.yaml`, the generated overlay.
`mihomo.yaml` is structurally **untouched** by this change: only a header
comment names the tool.

**Where the rules live.** The overlay's shape is a pure function, not a merge
tool argument: `liftProvider` in `tools/mihomo/src/tweaks.ts` returns the overlay
plus a `skipped` list, which the renderer reports separately (a non-config report
channel). This keeps the mapping table — including the
`dns.nameserver` → `dns.proxy-server-nameserver` rename — readable in one typed
file instead of a 500-character single-quoted argument. One merge constraint the
rules respect: an empty **array** overwrites on merge while an empty **map** is a
no-op, so `proxy-server-nameserver` is left out (never emitted as `null` or `[]`)
— otherwise a fresh machine's fallback would be clobbered. `tests/tweaks_test.ts`
covers each rule.

**Dual-shell constraint.** `mihomo-api.sh` is sourced from `~/.zshrc`, so its
functions run under **zsh**, not bash, despite the shebang. Two bugs were found
here the hard way while the lifting still lived in that file: `path` is a zsh
special parameter tied to `$PATH`, so `read -r path` replaced `$PATH` with the
file path and every later command lookup failed (silently dropping the tweaks);
and zsh arrays are 1-indexed, so `${a[0]}` is empty where bash's is the first
element. The tool now owns the logic in TypeScript, so neither trap applies; the
facade's header still warns about both.

## Sources

* mihomo `Meta` @ `88dcbf7` — `adapter/provider/provider.go` (`ProxySchema`,
  `NewProxiesParser`), `adapter/provider/parser.go` (`proxyProviderSchema`),
  `main.go` (`-f`), `config/config.go` (`use-hosts` default, `parseHosts`,
  `respect-rules` check), `dns/resolver.go` (`Invalid`, `ProxyResolver` build),
  `dns/middleware.go` (`withHosts`, `useHosts` gate), `dns/enhancer.go`,
  `hub/executor/executor.go` (`updateDNS`, `updateHosts`),
  `component/resolver/resolver.go` (`DefaultHosts` fast path),
  `component/dialer/dialer.go` (`parseAddr`), `adapter/outbound/util.go`.
* Meta-Docs: `docs/config/proxy-providers/index.en.md`,
  `docs/config/dns/index.en.md`, `docs/config/dns/hosts.md`,
  `docs/handbook/syntax.md` (wildcards).
* Clash Verge Rev docs: Merge Configuration, Subscription Import
  (Remote profile + Merge/Script ordering).
* Local evidence: `~/.config/mihomo/providers.yaml`,
  `proxy_providers/e-ix.yaml`, `mihomo_runtime.yaml`, `mihomo-api.sh`.
