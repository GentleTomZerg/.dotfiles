// End-to-end gate: render a fixture shaped like the REAL mihomo.yaml through
// the production render pipeline and let the REAL `mihomo` binary judge it.
//
// This exercises the class of bug the prototype's flow-style gotcha caught: the
// template ships `proxy-providers: {}` as a flow-style empty map, and filling it
// while it stays in flow style emits YAML Go's parser rejects. A fake runner
// cannot see that, so this test shells out to the installed binary and is NOT
// part of the permission-free suite (`deno task test`); run it with
// `deno task gate`.
//
// Everything happens in a fresh temp dir: it never reads or writes the real
// config directory, and every temp dir is removed when the test exits.
import { assertEquals, assertStringIncludes } from "@std/assert";
import { RealCommandRunner } from "../src/command.ts";
import { loadSettings } from "../src/config.ts";
import { renderConfig } from "../src/render.ts";
import { recordingReporter } from "./fake_report.ts";

/** Mirrors the real template's structure: the flow map, the anchors, the merges. */
const TEMPLATE = `mixed-port: 7890
proxy-providers: {}
proxies:
  - name: direct
    type: direct
proxy-groups:
  - name: 默认
    type: select
    proxies: [direct]
dns:
  enable: true
  enhanced-mode: fake-ip
  fake-ip-filter:
    - "+.lan"
  nameserver:
    - https://template.example.test/dns-query
rules:
  - MATCH,默认
rule-anchor:
  ip: &ip { type: http, interval: 86400, behavior: ipcidr, format: mrs }
  domain: &domain { type: http, interval: 86400, behavior: domain, format: mrs }
rule-providers:
  direct:
    !!merge <<: *domain
    url: "https://example.test/direct.mrs"
    path: ./rules/direct.mrs
`;

const PROVIDERS = `proxy-providers:
  airport:
    type: http
    url: "https://example.test/sub?token=dummy"
    interval: 3600
    path: ./proxy_providers/airport.yaml
dns:
  proxy-server-nameserver:
    - https://fallback.example.test/dns-query
`;

/** A cache whose dns.nameserver is lifted into the generated overlay. */
const CACHE = `proxies:
  - name: node-1
    type: ss
    server: node-1.example.test
    port: 8388
    cipher: aes-128-gcm
    password: dummy
dns:
  nameserver:
    - https://zone.example.test/api-query
`;

// The lift path only ever emits `proxy-server-nameserver` as an array, so the
// scalar malformation is injected through the providers.yaml fallback — the
// merged runtime still carries it into the same `dns:` block the gate reads.
const PROVIDERS_BROKEN = `proxy-providers:
  airport:
    type: http
    url: "https://example.test/sub?token=dummy"
    path: ./proxy_providers/airport.yaml
dns:
  proxy-server-nameserver: https://fallback.example.test/dns-query
`;

async function fixtureDir(files: Record<string, string>): Promise<string> {
  const dir = await Deno.makeTempDir({ prefix: "mihomo-gate-" });
  for (const [relative, text] of Object.entries(files)) {
    const path = `${dir}/${relative}`;
    await Deno.mkdir(path.slice(0, path.lastIndexOf("/")), { recursive: true });
    await Deno.writeTextFile(path, text);
  }
  return dir;
}

async function exists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch {
    return false;
  }
}

Deno.test("the gate accepts a runtime rendered from a real-shaped template", async () => {
  const dir = await fixtureDir({
    "mihomo.yaml": TEMPLATE,
    "providers.yaml": PROVIDERS,
    "proxy_providers/airport.yaml": CACHE,
  });
  try {
    const settings = loadSettings({ MIHOMO_CONFIG_PATH: dir });
    const runner = new RealCommandRunner();
    const { report, err } = recordingReporter();

    const result = await renderConfig(settings, runner, report);

    assertEquals(result.code, 0, `render failed: ${err.join("\n")}`);
    // Run the binary explicitly too: this is the assertion the task requires.
    const check = await runner.run("mihomo", [
      "-t",
      "-d",
      dir,
      "-f",
      settings.runtimePath,
    ]);
    assertEquals(check.code, 0, `mihomo -t rejected the runtime: ${check.stderr}`);
  } finally {
    await Deno.remove(dir, { recursive: true });
  }
});

Deno.test("the gate rejects a scalar dns.proxy-server-nameserver and drops the runtime", async () => {
  const dir = await fixtureDir({
    "mihomo.yaml": TEMPLATE,
    "providers.yaml": PROVIDERS_BROKEN,
  });
  try {
    const settings = loadSettings({ MIHOMO_CONFIG_PATH: dir });
    const { report, err } = recordingReporter();

    const result = await renderConfig(settings, new RealCommandRunner(), report);

    assertEquals(result.code, 1);
    // mihomo's own verdict reaches stderr...
    assertStringIncludes(
      err.join("\n"),
      "Error: rendered config failed 'mihomo -t'; not starting.",
    );
    assertStringIncludes(err.join("\n"), "test failed");
    // ...and the rejected runtime is not left behind.
    assertEquals(await exists(settings.runtimePath), false);
  } finally {
    await Deno.remove(dir, { recursive: true });
  }
});
