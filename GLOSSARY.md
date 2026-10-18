# dotfiles

Stowed configuration packages. Only one package has vocabulary of its own, so
this file is a single glossary rather than a map to several.

## mihomo

**airport**:
The proxy vendor whose subscription a provider fetches.
_Avoid_: provider, subscription

**base**:
The tracked, publishable mihomo config — ports, TUN, sniffer, `dns:`, groups,
rules. Lives at `templates/base.yaml`.
_Avoid_: template, main config

**cache**:
The document mihomo fetches for a provider and keeps at
`proxy_providers/<name>.yaml` — the airport's own config. The lift rule's input.
_Avoid_: provider, provider file

**example**:
A `templates/*.example.*` file — copied into `user/`, after which the copy is
that machine's to edit.
_Avoid_: template

**seed** (verb):
To copy an example into `user/`. The example stays upstream; the copy is the
machine's.

**lift**:
To take a key out of a provider document.
_Avoid_: extract, override

**lift rule**:
The yq program that decides which keys of a provider document are lifted.
Yours: `user/provider-lift.yq`, seeded from
`templates/provider-lift.example.yq`.
_Avoid_: override, template-override, tweaks

**overlay**:
The lift rule's output (`generated/provider-overlay.yaml`) — the keys lifted
from a provider document, merged last so they win over base and providers.
_Avoid_: override, patch

**provider**:
One `proxy-providers` entry: an airport subscription, defined in
`user/providers.yaml`.
_Avoid_: airport, subscription

**runtime**:
`generated/mihomo-runtime.yaml` — the single document mihomo is launched with,
rebuilt from scratch on every start.
_Avoid_: config, final config

**subscription**:
The airport's URL, which carries a personal token. Only ever in
`user/providers.yaml`.
_Avoid_: provider, feed

**fallback** (retired):
A resolver that used to sit in `user/providers.yaml` and answer before the first
subscription fetch. Base's `dns:` answers that window now. If old commits
mention a fallback layer, this is what it was.
