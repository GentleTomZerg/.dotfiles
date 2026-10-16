import { assertEquals, assertStringIncludes } from "@std/assert";
import { loadSettings, type Settings } from "../src/config.ts";
import { startProxy, stopProxy } from "../src/lifecycle.ts";
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

/** A cache whose lifted resolver matches the fallback, so render reports no drift. */
const CACHE = `proxies:
  - name: node-1
    type: ss
dns:
  nameserver:
    - https://fallback.example.test/dns-query
`;

function testSettings(env: Record<string, string | undefined> = {}): Settings {
  return loadSettings({
    MIHOMO_CONFIG_PATH: CONFIG_DIR,
    NETWORK_SERVICE: "Wi-Fi",
    MIHOMO_RETRY_TRIES: "1",
    MIHOMO_RETRY_DELAY: "0",
    ...env,
  });
}

/** In-memory file access so the lifecycle tests render without touching disk. */
function fakeFiles(entries: Record<string, string>) {
  const files = new Map(Object.entries(entries));
  const removed: string[] = [];
  return {
    files,
    removed,
    read: (path: string): Promise<string> =>
      files.has(path)
        ? Promise.resolve(files.get(path) as string)
        : Promise.reject(new Deno.errors.NotFound(path)),
    write: (path: string, data: string): Promise<void> => {
      files.set(path, data);
      return Promise.resolve();
    },
    remove: (path: string): Promise<void> => {
      files.delete(path);
      removed.push(path);
      return Promise.resolve();
    },
  };
}

function deps(files: ReturnType<typeof fakeFiles>) {
  return { readFile: files.read, writeFile: files.write, removeFile: files.remove };
}

/** A healthy proxy whose process only appears once `sudo -b mihomo` has run. */
function workingProxy(platform: "Darwin" | "Linux"): FakeCommandRunner {
  let launched = false;
  return new FakeCommandRunner((command, args) => {
    if (command === "pgrep") return launched ? ok("4242\n") : fail();
    if (command === "uname") return ok(`${platform}\n`);
    if (command === "scutil") return ok("  nameserver[0] : 198.18.0.2\n");
    if (command === "sudo" && args[0] === "-b") launched = true;
    return ok();
  });
}

const ok = (stdout = "") => ({ code: 0, stdout, stderr: "" });
const fail = () => ({ code: 1, stdout: "", stderr: "" });

Deno.test("start refuses a duplicate instance without touching anything", async () => {
  const { report, out, err } = recordingReporter();
  // No file seams and no permissions: reaching render would throw NotCapable.
  const runner = new FakeCommandRunner(() => ok("4242\n"));

  const code = await startProxy(testSettings(), runner, report);

  assertEquals(code, 1);
  assertEquals(out, ["mihomo has already started."]);
  assertEquals(err, []);
  assertEquals(runner.calls.map((call) => [call.command, ...call.args]), [
    ["pgrep", "-x", "mihomo"],
  ]);
});

Deno.test("start stops before sudo when the render fails", async () => {
  const settings = testSettings();
  const files = fakeFiles({ [settings.templatePath]: TEMPLATE }); // providers.yaml missing
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) => command === "pgrep" ? fail() : ok());

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 1);
  assertEquals(out, []);
  assertEquals(err, [
    `Error: Providers file not found at ${settings.providersPath}`,
    "startproxy: FAILED - the runtime config could not be rendered",
  ]);
  // The guard ran, then render failed; sudo, DNS and launch never happened.
  assertEquals(runner.calls.map((call) => [call.command, ...call.args]), [
    ["pgrep", "-x", "mihomo"],
  ]);
});

Deno.test("start asks for the sudo password interactively and stops when it fails", async () => {
  const settings = testSettings();
  const files = fakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
  });
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "pgrep") return fail();
    if (command === "sudo" && args[0] === "-v") return fail();
    return ok();
  });

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 1);
  assertEquals(err, ["sudo authentication failed."]);
  const sudoCall = runner.calls.find((call) => call.command === "sudo" && call.args[0] === "-v");
  assertEquals(sudoCall?.options, { stdin: "inherit", capture: false });
  // Nothing was launched or repointed once sudo refused.
  assertEquals(
    runner.calls.some((call) => call.args[0] === "-b" || call.args[0] === "networksetup"),
    false,
  );
  assertStringIncludes(out.join("\n"), "Runtime config written to");
});

Deno.test("start points macOS DNS at the virtual IP, launches mihomo and succeeds on all checks", async () => {
  const settings = testSettings();
  const files = fakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const { report, out, err } = recordingReporter();
  const runner = workingProxy("Darwin");

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 0);
  assertEquals(err, []);
  assertEquals(out, [
    "render: node DNS from airport:",
    "          https://fallback.example.test/dns-query",
    `Runtime config written to ${settings.runtimePath}`,
    `mihomo started with config: ${settings.runtimePath}`,
    "status: ok - mihomo running, API controller up",
    "status: ok - proxy forwards to the open internet",
    "status: ok - dashboard served",
    "status: ok - system DNS routed to mihomo",
    "status: all checks passed",
    "startproxy: mihomo fully working (all statusproxy checks passed)",
  ]);
  assertEquals(
    runner.calls.some((call) =>
      call.command === "sudo" && call.args.join(" ") ===
        "networksetup -setdnsservers Wi-Fi 198.18.0.2"
    ),
    true,
  );
  assertEquals(
    runner.calls.some((call) =>
      call.command === "sudo" &&
      call.args.join(" ") === `-b mihomo -d ${CONFIG_DIR} -f ${settings.runtimePath}`
    ),
    true,
  );
});

Deno.test("start leaves DNS alone on non-macOS", async () => {
  const settings = testSettings();
  const files = fakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const { report } = recordingReporter();
  const runner = workingProxy("Linux");

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 0);
  assertEquals(runner.calls.some((call) => call.args.includes("networksetup")), false);
  assertEquals(runner.calls.some((call) => call.command === "scutil"), false);
});

Deno.test("start fails and names the layer when a status check fails", async () => {
  const settings = testSettings();
  const files = fakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
    [CACHE_PATH]: CACHE,
  });
  const { report, out, err } = recordingReporter();
  let launched = false;
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "pgrep") return launched ? ok("4242\n") : fail();
    if (command === "uname") return ok("Linux\n");
    if (command === "curl" && args.at(-1) === `${settings.controllerUrl}/version`) return fail();
    if (command === "sudo" && args[0] === "-b") launched = true;
    return ok();
  });

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 1);
  assertEquals(err, [
    `status: FAIL - API controller not responding on ${settings.controllerUrl}`,
    "startproxy: FAILED - verify the statusproxy lines above",
  ]);
  assertEquals(
    out.includes("startproxy: mihomo fully working (all statusproxy checks passed)"),
    false,
  );
});

Deno.test("start nudges a restart without failing when no provider resolver was lifted", async () => {
  const settings = testSettings();
  const files = fakeFiles({
    [settings.templatePath]: TEMPLATE,
    [settings.providersPath]: PROVIDERS,
  }); // no cache fetched yet
  const { report, out, err } = recordingReporter();
  const runner = workingProxy("Darwin");

  const code = await startProxy(settings, runner, report, deps(files));

  assertEquals(code, 0);
  assertEquals(err, []);
  assertStringIncludes(out.join("\n"), "startproxy: note - no provider dns: was available to lift");
  assertStringIncludes(out.join("\n"), "Restart the proxy (stopproxy; startproxy)");
  assertEquals(out.at(-1), "startproxy: mihomo fully working (all statusproxy checks passed)");
});

Deno.test("stop reports and fails when mihomo is not running", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => fail());

  const code = await stopProxy(testSettings(), runner, report);

  assertEquals(code, 1);
  assertEquals(out, ["mihomo is not running"]);
  assertEquals(err, []);
  assertEquals(runner.calls.map((call) => [call.command, ...call.args]), [
    ["pgrep", "-x", "mihomo"],
  ]);
});

Deno.test("stop kills the running process and resets macOS DNS to the system default", async () => {
  const settings = testSettings();
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "pgrep") return ok("4242\n");
    if (command === "sudo" && args[0] === "pgrep") return ok("4242\n");
    if (command === "uname") return ok("Darwin\n");
    return ok();
  });

  const code = await stopProxy(settings, runner, report);

  assertEquals(code, 0);
  assertEquals(out, []);
  assertEquals(err, []);
  assertEquals(runner.calls.map((call) => [call.command, ...call.args]), [
    ["pgrep", "-x", "mihomo"],
    ["sudo", "pgrep", "-x", "mihomo"],
    ["sudo", "kill", "4242"],
    ["uname", "-s"],
    ["sudo", "networksetup", "-setdnsservers", "Wi-Fi", "Empty"],
  ]);
});

Deno.test("stop leaves DNS alone on non-macOS", async () => {
  const settings = testSettings();
  const { report } = recordingReporter();
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "pgrep") return ok("4242\n");
    if (command === "sudo" && args[0] === "pgrep") return ok("4242\n");
    if (command === "uname") return ok("Linux\n");
    return ok();
  });

  const code = await stopProxy(settings, runner, report);

  assertEquals(code, 0);
  assertEquals(runner.calls.some((call) => call.args.includes("networksetup")), false);
});
