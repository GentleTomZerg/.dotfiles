import { assertEquals, assertStringIncludes } from "@std/assert";
import { parseDocument } from "@eemeli/yaml";
import { runCli } from "../src/cli.ts";
import { loadSettings, type Settings } from "../src/config.ts";
import type { Reporter } from "../src/report.ts";
import { renderConfig } from "../src/render.ts";
import { FakeCommandRunner } from "./fake_command.ts";
import { recordingReporter } from "./fake_report.ts";

const CONFIG_DIR = "/cfg";
const CACHE_PATH = `${CONFIG_DIR}/proxy_providers/airport.yaml`;

const TEMPLATE = `mixed-port: 7890
proxy-providers: {}
proxies:
  - name: direct
    type: direct
dns:
  enable: true
  nameserver:
    - https://template.example.test/dns-query
  fake-ip-filter:
    - "+.lan"
rule-anchor:
  ip: &ip { type: http, interval: 86400, behavior: ipcidr, format: mrs }
  domain: &domain { type: http, interval: 86400, behavior: domain, format: mrs }
rule-providers:
  direct:
    !!merge <<: *domain
    url: "https://example.test/direct.mrs"
    path: ./rules/direct.mrs
`;

const PROVIDERS = `mixed-port: 7891
proxy-providers:
  airport:
    type: http
    url: "https://example.test/sub?token=dummy"
    interval: 3600
    path: ./proxy_providers/airport.yaml
dns:
  proxy-server-nameserver:
    - https://fallback.example.test/dns-query
`;

const PROVIDERS_MULTI = `proxy-providers:
  airport:
    type: http
    url: "https://example.test/sub?token=dummy"
    path: ./proxy_providers/airport.yaml
  second:
    type: http
    url: "https://example.test/second?token=dummy"
    path: ./proxy_providers/second.yaml
  nopath:
    type: http
    url: "https://example.test/nopath?token=dummy"
dns:
  proxy-server-nameserver:
    - https://fallback.example.test/dns-query
`;

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
  use-hosts: true
  fake-ip-filter:
    - "+.stun.example.test"
hosts:
  "+.example.test": 127.0.0.1
`;

/** In-memory stand-in for the filesystem: the suite never touches a real path. */
class FakeFiles {
  readonly files = new Map<string, string>();
  readonly removed: string[] = [];

  constructor(entries: Record<string, string>) {
    for (const [path, text] of Object.entries(entries)) this.files.set(path, text);
  }

  readonly read = (path: string): Promise<string> => {
    const text = this.files.get(path);
    return text === undefined
      ? Promise.reject(new Deno.errors.NotFound(`fake file not found: ${path}`))
      : Promise.resolve(text);
  };

  readonly write = (path: string, data: string): Promise<void> => {
    this.files.set(path, data);
    return Promise.resolve();
  };

  readonly remove = (path: string): Promise<void> => {
    this.files.delete(path);
    this.removed.push(path);
    return Promise.resolve();
  };
}

function defaultSettings(): Settings {
  return loadSettings({ MIHOMO_CONFIG_PATH: CONFIG_DIR });
}

function acceptingValidator(): FakeCommandRunner {
  return new FakeCommandRunner(() => ({ code: 0, stdout: "", stderr: "" }));
}

function render(
  files: FakeFiles,
  runner: FakeCommandRunner,
  report: Reporter,
  settings: Settings = defaultSettings(),
) {
  return renderConfig(settings, runner, report, files.read, files.write, files.remove);
}

/** Read the written YAML back as plain data, resolving the template's merge tags. */
function resolveYaml(text: string): Record<string, unknown> {
  return parseDocument(text, { merge: true }).toJS() as Record<string, unknown>;
}

function at(node: unknown, ...keys: string[]): unknown {
  let current = node;
  for (const key of keys) {
    current = (current as Record<string, unknown> | undefined)?.[key];
  }
  return current;
}

Deno.test("render renders template, then providers, then the lifted overlay, with the overlay winning", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });

  const result = await render(files, acceptingValidator(), recordingReporter().report);

  assertEquals(result.code, 0);
  const runtime = resolveYaml(files.files.get(settings.runtimePath) ?? "");
  // providers win over the template
  assertEquals(at(runtime, "mixed-port"), 7891);
  assertEquals(
    at(runtime, "proxy-providers", "airport", "url"),
    "https://example.test/sub?token=dummy",
  );
  assertEquals(at(runtime, "proxy-providers", "airport", "path"), "./proxy_providers/airport.yaml");
  // template-only keys survive; the provider cache is lifted, never merged whole
  assertEquals(at(runtime, "proxies"), [{ name: "direct", type: "direct" }]);
  assertEquals(at(runtime, "dns", "nameserver"), ["https://template.example.test/dns-query"]);
  // the overlay wins over both the template and the providers fallback
  assertEquals(at(runtime, "dns", "proxy-server-nameserver"), [
    "https://zone.example.test/api-query",
  ]);
  // arrays replace wholesale instead of appending
  assertEquals(at(runtime, "dns", "fake-ip-filter"), ["+.stun.example.test"]);
  assertEquals(at(runtime, "dns", "use-hosts"), true);
  assertEquals(at(runtime, "hosts"), { "+.example.test": "127.0.0.1" });
});

Deno.test("render keeps the template's anchors and merge tags with their meaning intact", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });

  await render(files, acceptingValidator(), recordingReporter().report);

  const text = files.files.get(settings.runtimePath) ?? "";
  assertStringIncludes(text, "&ip");
  assertStringIncludes(text, "&domain");
  assertStringIncludes(text, "!!merge <<: *domain");
  assertStringIncludes(text, "proxy-providers:");
  // the template's empty flow map must not drag the merged providers into flow style
  assertEquals(text.includes("proxy-providers: {"), false);
  // the alias still resolves to the anchored rule-provider defaults
  const rule = at(resolveYaml(text), "rule-providers", "direct");
  assertEquals(at(rule, "interval"), 86400);
  assertEquals(at(rule, "behavior"), "domain");
});

Deno.test("render validates the rendered config with mihomo -t in the config dir", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const runner = acceptingValidator();

  await render(files, runner, recordingReporter().report);

  assertEquals(runner.calls.map((call) => [call.command, call.args]), [
    ["mihomo", ["-t", "-d", CONFIG_DIR, "-f", `${CONFIG_DIR}/mihomo_runtime.yaml`]],
  ]);
});

Deno.test("render derives the config dir from the environment, not the tool's location", async () => {
  const settings = loadSettings({ HOME: "/home/tester" });
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    "/home/tester/.config/mihomo/proxy_providers/airport.yaml": CACHE,
  });
  const runner = acceptingValidator();
  const { report, out } = recordingReporter();

  const result = await render(files, runner, report, settings);

  assertEquals(settings.configDir, "/home/tester/.config/mihomo");
  assertEquals(result.runtimePath, "/home/tester/.config/mihomo/mihomo_runtime.yaml");
  assertEquals(runner.calls[0].args[2], "/home/tester/.config/mihomo");
  assertStringIncludes(out[out.length - 1], "/home/tester/.config/mihomo");
});

Deno.test("render writes the overlay next to the runtime config and reports the lifted resolvers", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const { report, out, err } = recordingReporter();

  const result = await render(files, acceptingValidator(), report);

  assertEquals(
    resolveYaml(files.files.get(settings.tweaksPath) ?? ""),
    {
      dns: {
        "proxy-server-nameserver": ["https://zone.example.test/api-query"],
        "use-hosts": true,
        "fake-ip-filter": ["+.stun.example.test"],
      },
      hosts: { "+.example.test": "127.0.0.1" },
    },
  );
  assertEquals(result.selection.state, "found");
  assertEquals(result.selection.sourceName, "airport");
  assertEquals(out, [
    "render: node DNS from airport:",
    "          https://zone.example.test/api-query",
    `Runtime config written to ${settings.runtimePath}`,
  ]);
  assertEquals(err, [
    "render: NOTE - that differs from the dns: fallback in providers.yaml.",
    "        Update it so a machine with no cache yet still works.",
  ]);
});

Deno.test("render notes no drift when the lifted resolvers match the providers.yaml fallback", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS.replace(
      "https://fallback.example.test/dns-query",
      "https://zone.example.test/api-query",
    ),
    [CACHE_PATH]: CACHE,
  });
  const { report, err } = recordingReporter();

  const result = await render(files, acceptingValidator(), report);

  assertEquals(result.code, 0);
  assertEquals(result.selection.state, "found");
  assertEquals(err, []);
});

Deno.test("render writes an empty overlay and lifts nothing when no cache carries a usable dns: block", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS.replace(
      /dns:\n {2}proxy-server-nameserver:\n {4}- https:\/\/fallback\.example\.test\/dns-query\n/,
      "",
    ),
    [CACHE_PATH]: "proxies:\n  - name: node-1\n",
  });
  const { report, out, err } = recordingReporter();

  const result = await render(files, acceptingValidator(), report);

  assertEquals(result.code, 0);
  assertEquals(result.selection.state, "missing");
  assertEquals(files.files.get(settings.tweaksPath), "{}\n");
  const runtime = resolveYaml(files.files.get(settings.runtimePath) ?? "");
  assertEquals(at(runtime, "dns"), {
    enable: true,
    nameserver: ["https://template.example.test/dns-query"],
    "fake-ip-filter": ["+.lan"],
  });
  assertEquals(out, [`Runtime config written to ${settings.runtimePath}`]);
  assertEquals(err, []);
});

Deno.test("render warns about providers without a path and about several contributing caches", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS_MULTI,
    [CACHE_PATH]: CACHE,
    [`${CONFIG_DIR}/proxy_providers/second.yaml`]: CACHE.replace(
      "https://zone.example.test/api-query",
      "https://second.example.test/api-query",
    ),
  });
  const { report, err } = recordingReporter();

  const result = await render(files, acceptingValidator(), report);

  assertEquals(result.code, 0);
  assertEquals(result.selection.state, "multi");
  assertEquals(result.selection.ignoredNames, ["second"]);
  assertEquals(err, [
    "Warning: proxy-provider 'nopath' sets no path:, so its cache cannot be located",
    "         and its dns: is not lifted.",
    "Warning: more than one proxy-provider ships a dns: block, and the multi-provider",
    "         policy is not designed yet. Using airport, ignoring:",
    "           second",
    "render: NOTE - that differs from the dns: fallback in providers.yaml.",
    "        Update it so a machine with no cache yet still works.",
  ]);
});

Deno.test("render warns about circular resolvers it had to skip", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE.replace(
      "    - https://zone.example.test/api-query\n",
      "    - 1.1.1.1#RULES\n    - https://zone.example.test/api-query\n",
    ),
  });
  const { report, err } = recordingReporter();

  const result = await render(files, acceptingValidator(), report);

  assertEquals(result.code, 0);
  assertEquals(result.selection.skipped, ["1.1.1.1#RULES"]);
  assertStringIncludes(
    err.join("\n"),
    "Warning: skipping circular DNS resolver(s) from airport,",
  );
  assertStringIncludes(err.join("\n"), "           1.1.1.1#RULES");
});

Deno.test("render fails without touching anything when providers.yaml is missing", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({ [settings.templatePath]: TEMPLATE });
  const runner = acceptingValidator();
  const { report, out, err } = recordingReporter();

  const result = await render(files, runner, report);

  assertEquals(result.code, 1);
  assertEquals(err, [`Error: Providers file not found at ${settings.providersPath}`]);
  assertEquals(out, []);
  assertEquals(runner.calls, []);
  assertEquals(files.files.has(settings.runtimePath), false);
  assertEquals(files.files.has(settings.tweaksPath), false);
});

Deno.test("render prints the validator's own output and deletes the partial config when mihomo -t fails", async () => {
  const settings = defaultSettings();
  const files = new FakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const runner = new FakeCommandRunner(() => ({
    code: 1,
    stdout: "",
    stderr: 'level=error msg="Parse config error" error="line 6: did not find expected key"\n',
  }));
  const { report, err } = recordingReporter();

  const result = await render(files, runner, report);

  assertEquals(result.code, 1);
  assertEquals(result.runtimePath, settings.runtimePath);
  assertStringIncludes(
    err.join("\n"),
    "Error: rendered config failed 'mihomo -t'; not starting.",
  );
  assertStringIncludes(err.join("\n"), "line 6: did not find expected key");
  assertEquals(files.removed, [settings.runtimePath]);
  assertEquals(files.files.has(settings.runtimePath), false);
});

Deno.test("runCli dispatches render with settings from the injected env and rejects unknown subcommands", async () => {
  const env = { MIHOMO_CONFIG_PATH: "/nowhere" };

  const { report: unknownReport, err: unknownErr } = recordingReporter();
  const unknown = await runCli(["frobnicate"], { report: unknownReport, env });
  assertEquals(unknown, 1);
  assertEquals(unknownErr, [
    "Error: unknown subcommand 'frobnicate'.",
    "Usage: mihomo <render|start|stop|status>",
  ]);

  const { report: noArgsReport, err: noArgsErr } = recordingReporter();
  const noArgs = await runCli([], { report: noArgsReport, env });
  assertEquals(noArgs, 1);
  assertEquals(noArgsErr, [
    "Error: no subcommand given.",
    "Usage: mihomo <render|start|stop|status>",
  ]);

  const { report: renderReport, err: renderErr } = recordingReporter();
  const rendered = await runCli(["render"], {
    runner: acceptingValidator(),
    report: renderReport,
    env,
  });
  assertEquals(rendered, 1);
  assertEquals(renderErr, [
    "Error: Providers file not found at /nowhere/providers.yaml",
  ]);
});
