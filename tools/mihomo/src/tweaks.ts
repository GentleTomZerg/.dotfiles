export type TweaksState = "missing" | "found" | "multi";

export interface ProviderRef {
  name: string;
  /** Absolute path to the provider's cached document. */
  path: string;
}

export interface LocatedProviders {
  refs: ProviderRef[];
  noPath: string[];
}

/**
 * Read `.proxy-providers[].path` out of the parsed providers config. Relative
 * paths are resolved against `configDir`; providers without a `path:` are
 * reported by name so the caller can warn that their cache cannot be located.
 */
export function locateProviders(providersConfig: unknown, configDir: string): LocatedProviders {
  const entries = asMap(asMap(providersConfig)?.["proxy-providers"]) ?? {};
  const refs: ProviderRef[] = [];
  const noPath: string[] = [];
  for (const [name, entry] of Object.entries(entries)) {
    const path = asMap(entry)?.["path"];
    if (typeof path !== "string" || path === "") {
      noPath.push(name);
      continue;
    }
    refs.push({ name, path: resolvePath(path, configDir) });
  }
  return { refs, noPath };
}

export interface Lift {
  overlay: Record<string, unknown>;
  skipped: string[];
}

const RESOLVER_KEY = "proxy-server-nameserver";

/**
 * Port of `provider-tweaks.yq` for one provider document (already parsed to
 * plain JS). Renames `dns.nameserver` to `dns.proxy-server-nameserver`, passes
 * through `use-hosts`, `fake-ip-filter` and root `hosts`, drops the keys the
 * template owns, and reports circular candidate resolvers as `skipped`.
 *
 * The overlay never contains a `null` or an empty array: either would replace a
 * committed template key instead of leaving it alone on merge.
 */
export function liftProvider(doc: unknown): Lift {
  const root = asMap(doc) ?? {};
  const dns = asMap(root["dns"]) ?? {};

  const candidates = [
    ...asList(dns[RESOLVER_KEY]),
    ...asList(dns["nameserver"]),
  ];
  const kept: unknown[] = [];
  const skipped: string[] = [];
  for (const candidate of candidates) {
    if (isCircular(candidate)) {
      skipped.push(String(candidate));
    } else {
      kept.push(candidate);
    }
  }

  const dnsOverlay: Record<string, unknown> = {};
  const resolvers = unique(kept);
  if (resolvers.length > 0) dnsOverlay[RESOLVER_KEY] = resolvers;
  addUnlessEmpty(dnsOverlay, "use-hosts", dns["use-hosts"]);
  addUnlessEmpty(dnsOverlay, "fake-ip-filter", dns["fake-ip-filter"]);

  const overlay: Record<string, unknown> = {};
  if (Object.keys(dnsOverlay).length > 0) overlay["dns"] = dnsOverlay;
  addUnlessEmpty(overlay, "hosts", root["hosts"]);
  return { overlay, skipped };
}

export interface LoadedProvider {
  name: string;
  path: string;
  doc: unknown;
}

export interface Selection {
  /** {} when nothing was lifted. */
  overlay: Record<string, unknown>;
  /** Circular resolvers from the chosen cache, in provider order. */
  skipped: string[];
  state: TweaksState;
  /** The lifted `dns.proxy-server-nameserver` values. */
  applied: string[];
  sourceName: string | null;
  sourcePath: string | null;
  /** Other caches that carried a `dns:` block, so the caller can warn. */
  ignoredNames: string[];
}

/**
 * Choose the first loaded provider whose `dns:` block yields a lifted
 * `proxy-server-nameserver`. One such provider is `found`, several are `multi`;
 * with none the state is `missing` and the overlay is inert.
 */
export function selectTweaks(providers: LoadedProvider[]): Selection {
  const lifts = providers.map((p) => ({ provider: p, lift: liftProvider(p.doc) }));
  const contributors = lifts.filter((l) => liftedResolvers(l.lift).length > 0);
  if (contributors.length === 0) {
    return {
      overlay: {},
      skipped: [],
      state: "missing",
      applied: [],
      sourceName: null,
      sourcePath: null,
      ignoredNames: [],
    };
  }

  const source = contributors[0];
  const dnsCarriers = lifts.filter((l) => carriesDns(l.provider));
  return {
    overlay: source.lift.overlay,
    skipped: source.lift.skipped,
    state: contributors.length === 1 ? "found" : "multi",
    applied: liftedResolvers(source.lift),
    sourceName: source.provider.name,
    sourcePath: source.provider.path,
    ignoredNames: dnsCarriers
      .filter((l) => l.provider !== source.provider)
      .map((l) => l.provider.name),
  };
}

function liftedResolvers(lift: Lift): string[] {
  const resolvers = asMap(lift.overlay["dns"])?.[RESOLVER_KEY];
  return Array.isArray(resolvers) ? resolvers.map(String) : [];
}

function carriesDns(provider: LoadedProvider): boolean {
  return asMap(provider.doc)?.["dns"] != null;
}

/** A `#`-suffix must contain `=` and must not be `RULES`; anything else is circular. */
function isCircular(candidate: unknown): boolean {
  if (typeof candidate !== "string") return false;
  const hash = candidate.indexOf("#");
  if (hash === -1) return false;
  const head = candidate.slice(hash + 1).split("#")[0].split("&")[0];
  return head === "RULES" || !head.includes("=");
}

function resolvePath(path: string, configDir: string): string {
  if (path.startsWith("/")) return path;
  const root = configDir.endsWith("/") ? configDir.slice(0, -1) : configDir;
  return `${root}/${path.startsWith("./") ? path.slice(2) : path}`;
}

function addUnlessEmpty(target: Record<string, unknown>, key: string, value: unknown): void {
  if (value === null || value === undefined) return;
  if (Array.isArray(value) && value.length === 0) return;
  target[key] = value;
}

/** Dedupe preserving first-occurrence order, matching yq's `unique` here. */
function unique<T>(items: T[]): T[] {
  const seen = new Set<T>();
  const out: T[] = [];
  for (const item of items) {
    if (seen.has(item)) continue;
    seen.add(item);
    out.push(item);
  }
  return out;
}

function asMap(value: unknown): Record<string, unknown> | undefined {
  if (value !== null && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return undefined;
}

function asList(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}
