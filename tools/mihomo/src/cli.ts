import { type CommandRunner, RealCommandRunner } from "./command.ts";
import { loadSettings, type Settings } from "./config.ts";
import { consoleReporter, type Reporter } from "./report.ts";
import { runStatus } from "./status.ts";

/** Everything a subcommand needs. Production values are built lazily in `runCli`. */
export interface CliDeps {
  settings: Settings;
  runner: CommandRunner;
  report: Reporter;
}

/**
 * Dispatch table keyed by the subcommand name `main.ts` passes in. Each entry
 * returns the process exit code.
 */
export const subcommands: Record<string, (deps: CliDeps) => Promise<number>> = {
  status: async ({ settings, runner, report }) =>
    (await runStatus(settings, runner, report)).ok ? 0 : 1,
};

/**
 * Run one subcommand. `deps` is for tests: when omitted, the real environment,
 * runner and reporter are built here, which is the only place that reads the
 * process environment.
 */
export async function runCli(args: string[], deps?: Partial<CliDeps>): Promise<number> {
  const resolved: CliDeps = {
    settings: deps?.settings ?? loadSettings(Deno.env.toObject()),
    runner: deps?.runner ?? new RealCommandRunner(),
    report: deps?.report ?? consoleReporter,
  };
  const [name] = args;
  const subcommand = name === undefined ? undefined : subcommands[name];
  if (subcommand === undefined) {
    resolved.report.err(`usage: mihomo <${Object.keys(subcommands).join("|")}>`);
    return 1;
  }
  return await subcommand(resolved);
}
