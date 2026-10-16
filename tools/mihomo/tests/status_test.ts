import { assertEquals } from "@std/assert";
import { loadSettings, type Settings } from "../src/config.ts";
import { runStatus } from "../src/status.ts";
import { FakeCommandRunner } from "./fake_command.ts";
import { recordingReporter } from "./fake_report.ts";

/** Settings small and fast enough to keep the suite below a second. */
function testSettings(env: Record<string, string | undefined> = {}): Settings {
  return loadSettings({
    HOME: "/home/example",
    MIHOMO_RETRY_TRIES: "2",
    MIHOMO_RETRY_DELAY: "0",
    ...env,
  });
}

Deno.test("runStatus fails fast when the mihomo process is not running", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 1, stdout: "", stderr: "" }));

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result, {
    ok: false,
    failures: 1,
    checks: [{ name: "process", ok: false }],
  });
  assertEquals(out, []);
  assertEquals(err, ["status: FAIL - mihomo is not running"]);
});

Deno.test("runStatus fails fast when the API controller is not responding", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) =>
    command === "pgrep"
      ? { code: 0, stdout: "4242\n", stderr: "" }
      : { code: 7, stdout: "", stderr: "" }
  );

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result, {
    ok: false,
    failures: 1,
    checks: [{ name: "process", ok: true }, { name: "controller", ok: false }],
  });
  assertEquals(out, []);
  assertEquals(err, ["status: FAIL - API controller not responding on http://127.0.0.1:9090"]);
  assertEquals(runner.calls.length, 3);
  assertEquals(runner.calls[1].args, ["-fs", "-o", "/dev/null", "http://127.0.0.1:9090/version"]);
});

Deno.test("runStatus prints a pass line per check on a working non-macOS machine", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) =>
    command === "uname"
      ? { code: 0, stdout: "Linux\n", stderr: "" }
      : { code: 0, stdout: "", stderr: "" }
  );

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result, {
    ok: true,
    failures: 0,
    checks: [
      { name: "process", ok: true },
      { name: "controller", ok: true },
      { name: "blocked-site", ok: true },
      { name: "dashboard", ok: true },
    ],
  });
  assertEquals(out, [
    "status: ok - mihomo running, API controller up",
    "status: ok - proxy forwards to the open internet",
    "status: ok - dashboard served",
    "status: all checks passed",
  ]);
  assertEquals(err, []);
  assertEquals(runner.calls.map((call) => [call.command, ...call.args]), [
    ["pgrep", "-x", "mihomo"],
    ["curl", "-fs", "-o", "/dev/null", "http://127.0.0.1:9090/version"],
    ["curl", "-fs", "-o", "/dev/null", "-x", "http://127.0.0.1:7890", "https://www.youtube.com"],
    ["curl", "-fsS", "-o", "/dev/null", "http://127.0.0.1:9090/ui/"],
    ["uname", "-s"],
  ]);
});

Deno.test("runStatus checks the system DNS pointer on macOS", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) => {
    if (command === "uname") return { code: 0, stdout: "Darwin\n", stderr: "" };
    if (command === "scutil") {
      return {
        code: 0,
        stdout: "resolver #1\n  nameserver[0] : 198.18.0.2\n",
        stderr: "",
      };
    }
    return { code: 0, stdout: "", stderr: "" };
  });

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result.checks.map((check) => check.name), [
    "process",
    "controller",
    "blocked-site",
    "dashboard",
    "dns",
  ]);
  assertEquals(result.ok, true);
  assertEquals(out, [
    "status: ok - mihomo running, API controller up",
    "status: ok - proxy forwards to the open internet",
    "status: ok - dashboard served",
    "status: ok - system DNS routed to mihomo",
    "status: all checks passed",
  ]);
  assertEquals(err, []);
  assertEquals(runner.calls.at(-1)?.args, ["--dns"]);
});

Deno.test("runStatus accumulates a failed DNS check and reports the count", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) => {
    if (command === "uname") return { code: 0, stdout: "Darwin\n", stderr: "" };
    if (command === "scutil") {
      return { code: 0, stdout: "resolver #1\n  nameserver[0] : 192.168.1.1\n", stderr: "" };
    }
    return { code: 0, stdout: "", stderr: "" };
  });

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result.ok, false);
  assertEquals(result.failures, 1);
  assertEquals(result.checks.at(-1), { name: "dns", ok: false });
  assertEquals(err, [
    "status: FAIL - system DNS not pointed at 198.18.0.2",
    "status: 1 check(s) failed",
  ]);
  assertEquals(out.includes("status: all checks passed"), false);
});

Deno.test("runStatus counts blocked-site and dashboard failures together", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "uname") return { code: 0, stdout: "Linux\n", stderr: "" };
    if (command === "curl" && args.includes("-x")) return { code: 28, stdout: "", stderr: "" };
    if (command === "curl" && args.at(-1)!.endsWith("/ui/")) {
      return { code: 22, stdout: "", stderr: "" };
    }
    return { code: 0, stdout: "", stderr: "" };
  });

  const result = await runStatus(testSettings(), runner, report);

  assertEquals(result, {
    ok: false,
    failures: 2,
    checks: [
      { name: "process", ok: true },
      { name: "controller", ok: true },
      { name: "blocked-site", ok: false },
      { name: "dashboard", ok: false },
    ],
  });
  assertEquals(out, ["status: ok - mihomo running, API controller up"]);
  assertEquals(err, [
    "status: FAIL - blocked site not reachable through http://127.0.0.1:7890",
    "status: FAIL - dashboard not served at http://127.0.0.1:9090/ui/",
    "status: 2 check(s) failed",
  ]);
});

Deno.test("runStatus spends the MIHOMO_RETRY_TRIES budget on each probe", async () => {
  const { report } = recordingReporter();
  const runner = new FakeCommandRunner((command, args) => {
    if (command === "uname") return { code: 0, stdout: "Linux\n", stderr: "" };
    if (command === "curl" && args.includes("-x")) return { code: 28, stdout: "", stderr: "" };
    return { code: 0, stdout: "", stderr: "" };
  });

  await runStatus(testSettings({ MIHOMO_RETRY_TRIES: "3" }), runner, report);

  const blockedAttempts = runner.calls.filter((call) =>
    call.command === "curl" && call.args.includes("-x")
  );
  assertEquals(blockedAttempts.length, 3);
});

Deno.test("runStatus gives up after the retry budget without probing again", async () => {
  const { report } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 1, stdout: "", stderr: "" }));

  await runStatus(testSettings({ MIHOMO_RETRY_TRIES: "1" }), runner, report);

  assertEquals(runner.calls.length, 1);
});

Deno.test("runStatus waits MIHOMO_RETRY_DELAY between attempts", async () => {
  const { report } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 1, stdout: "", stderr: "" }));

  const started = Date.now();
  await runStatus(
    testSettings({ MIHOMO_RETRY_TRIES: "2", MIHOMO_RETRY_DELAY: "0.2" }),
    runner,
    report,
  );

  assertEquals(Date.now() - started >= 150, true);
});
