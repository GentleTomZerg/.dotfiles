import type { CommandRunner } from "./command.ts";
import type { Settings } from "./config.ts";
import { isMacOS } from "./platform.ts";
import type { Reporter } from "./report.ts";

export interface StatusCheck {
  name: string;
  ok: boolean;
}

export interface StatusResult {
  ok: boolean;
  failures: number;
  checks: StatusCheck[];
}

/** The blocked site the shell used to prove the proxy reaches the open internet. */
const BLOCKED_SITE_URL = "https://www.youtube.com";

/**
 * Verify the running proxy the way `statusproxy` did: process and controller
 * first (failing fast, since nothing else can work without them), then the
 * blocked site, the dashboard and — on macOS — the system DNS pointer, which
 * accumulate into a failure count.
 */
export async function runStatus(
  settings: Settings,
  runner: CommandRunner,
  report: Reporter,
): Promise<StatusResult> {
  const checks: StatusCheck[] = [];

  const processRunning = await waitFor(settings, runner, "pgrep", ["-x", "mihomo"]);
  checks.push({ name: "process", ok: processRunning });
  if (!processRunning) {
    // Fail fast: with no process there is nothing to count or report beyond this.
    report.err("status: FAIL - mihomo is not running");
    return { ok: false, failures: 1, checks };
  }

  const controllerUp = await waitFor(settings, runner, "curl", [
    "-fs",
    "-o",
    "/dev/null",
    `${settings.controllerUrl}/version`,
  ]);
  checks.push({ name: "controller", ok: controllerUp });
  if (!controllerUp) {
    report.err(`status: FAIL - API controller not responding on ${settings.controllerUrl}`);
    return { ok: false, failures: 1, checks };
  }
  report.out("status: ok - mihomo running, API controller up");

  let failures = 0;

  const blockedSiteReachable = await waitFor(settings, runner, "curl", [
    "-fs",
    "-o",
    "/dev/null",
    "-x",
    settings.serviceUrl,
    BLOCKED_SITE_URL,
  ]);
  checks.push({ name: "blocked-site", ok: blockedSiteReachable });
  if (blockedSiteReachable) {
    report.out("status: ok - proxy forwards to the open internet");
  } else {
    failures++;
    report.err(`status: FAIL - blocked site not reachable through ${settings.serviceUrl}`);
  }

  const dashboard = await runner.run("curl", [
    "-fsS",
    "-o",
    "/dev/null",
    `${settings.controllerUrl}/ui/`,
  ]);
  checks.push({ name: "dashboard", ok: dashboard.code === 0 });
  if (dashboard.code === 0) {
    report.out("status: ok - dashboard served");
  } else {
    failures++;
    report.err(`status: FAIL - dashboard not served at ${settings.controllerUrl}/ui/`);
  }

  if (await isMacOS(runner)) {
    const scutil = await runner.run("scutil", ["--dns"]);
    const dnsPointed = scutil.code === 0 && scutil.stdout.includes(settings.dnsVirtualIp);
    checks.push({ name: "dns", ok: dnsPointed });
    if (dnsPointed) {
      report.out("status: ok - system DNS routed to mihomo");
    } else {
      failures++;
      report.err(`status: FAIL - system DNS not pointed at ${settings.dnsVirtualIp}`);
    }
  }

  if (failures > 0) {
    report.err(`status: ${failures} check(s) failed`);
    return { ok: false, failures, checks };
  }
  report.out("status: all checks passed");
  return { ok: true, failures, checks };
}

/** Run a probe until it succeeds or the budget is exhausted, sleeping between attempts. */
async function waitFor(
  settings: Settings,
  runner: CommandRunner,
  command: string,
  args: string[],
): Promise<boolean> {
  for (let attempt = 1; attempt <= settings.retryTries; attempt++) {
    const result = await runner.run(command, args);
    if (result.code === 0) return true;
    if (attempt < settings.retryTries) {
      await new Promise((resolve) => setTimeout(resolve, settings.retryDelay * 1000));
    }
  }
  return false;
}
