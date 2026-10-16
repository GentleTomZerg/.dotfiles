import type { CommandRunner } from "./command.ts";
import type { Settings } from "./config.ts";
import { type ReadFile, type RemoveFile, renderConfig, type WriteFile } from "./render.ts";
import type { Reporter } from "./report.ts";
import { runStatus } from "./status.ts";

/**
 * File seams injected into `renderConfig`, so a lifecycle test can drive the
 * whole render pipeline from memory. Omitted in production.
 */
export interface LifecycleDeps {
  readFile?: ReadFile;
  writeFile?: WriteFile;
  removeFile?: RemoveFile;
}

/**
 * Start mihomo in the order the shell `startproxy` used: refuse a duplicate,
 * render and validate the config (so a bad merge never reaches sudo), ask for
 * sudo once with the password prompt reaching the terminal, point macOS DNS at
 * the virtual IP, launch, and only succeed when every status check passes.
 */
export async function startProxy(
  settings: Settings,
  runner: CommandRunner,
  report: Reporter,
  deps: LifecycleDeps = {},
): Promise<number> {
  // 1. Guard against a duplicate instance — the probe has no side effects, so
  // nothing is touched when mihomo is already up.
  const alreadyRunning = await runner.run("pgrep", ["-x", "mihomo"]);
  if (alreadyRunning.code === 0) {
    report.out("mihomo has already started.");
    return 1;
  }

  // 2. Render and validate from the template + providers before asking for sudo.
  const rendered = await renderConfig(
    settings,
    runner,
    report,
    deps.readFile,
    deps.writeFile,
    deps.removeFile,
  );
  if (rendered.code !== 0) {
    report.err("startproxy: FAILED - the runtime config could not be rendered");
    return 1;
  }

  // 3. Cache sudo once. `stdin: "inherit"` and `capture: false` are what let the
  // password prompt reach the terminal instead of being swallowed by a pipe.
  const sudo = await runner.run("sudo", ["-v"], { stdin: "inherit", capture: false });
  if (sudo.code !== 0) {
    report.err("sudo authentication failed.");
    return 1;
  }

  // 4. On macOS, point system DNS at mihomo's virtual IP.
  if (await isMacOS(runner)) {
    await runner.run("sudo", [
      "networksetup",
      "-setdnsservers",
      settings.networkService,
      settings.dnsVirtualIp,
    ]);
  }

  // 5. Launch detached. `capture: false` is required: a captured stdout/stderr
  // pipe would stay open for as long as the backgrounded mihomo holds it, and
  // `child.output()` would never resolve.
  await runner.run(
    "sudo",
    ["-b", "mihomo", "-d", settings.configDir, "-f", settings.runtimePath],
    { capture: false },
  );
  report.out(`mihomo started with config: ${settings.runtimePath}`);

  // 6. The launch is only a success once the whole status suite passes.
  const status = await runStatus(settings, runner, report);
  if (!status.ok) {
    report.err("startproxy: FAILED - verify the statusproxy lines above");
    return 1;
  }

  // 7. Fresh machine: render ran before mihomo had fetched the subscription, so
  // no provider dns: existed to lift. The providers.yaml fallback still covers
  // node DNS — this is an action, not a failure, so the exit code stays 0.
  if (rendered.selection.state === "missing") {
    report.out("startproxy: note - no provider dns: was available to lift, so the fallback");
    report.out(
      "            in providers.yaml is in use. Restart the proxy (stopproxy; startproxy)",
    );
    report.out("            once the subscription has been fetched, to pick up the airport's own.");
  }

  report.out("startproxy: mihomo fully working (all statusproxy checks passed)");
  return 0;
}

/**
 * Stop mihomo the way `stopproxy` did: report and fail when it is not running,
 * otherwise `sudo kill` the pid and, on macOS, hand DNS back to the system.
 */
export async function stopProxy(
  settings: Settings,
  runner: CommandRunner,
  report: Reporter,
): Promise<number> {
  const running = await runner.run("pgrep", ["-x", "mihomo"]);
  if (running.code !== 0) {
    report.out("mihomo is not running");
    return 1;
  }

  // The shell read the pid through sudo so it could kill a root-owned process.
  const pid = await runner.run("sudo", ["pgrep", "-x", "mihomo"]);
  await runner.run("sudo", ["kill", pid.stdout.trim()]);

  if (await isMacOS(runner)) {
    await runner.run("sudo", [
      "networksetup",
      "-setdnsservers",
      settings.networkService,
      "Empty",
    ]);
  }
  return 0;
}

/** Platform probe through the command seam, so tests inject "Darwin" or "Linux". */
async function isMacOS(runner: CommandRunner): Promise<boolean> {
  const uname = await runner.run("uname", ["-s"]);
  return uname.code === 0 && uname.stdout.trim() === "Darwin";
}
