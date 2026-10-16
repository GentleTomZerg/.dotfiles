import { type CommandRunner, RealCommandRunner } from "./command.ts";
import { loadSettings, type Settings } from "./config.ts";
import { renderConfig } from "./render.ts";
import { consoleReporter, type Reporter } from "./report.ts";

/** One subcommand: settings, the command seam and a reporter in; exit code out. */
export type Subcommand = (
  settings: Settings,
  runner: CommandRunner,
  report: Reporter,
) => Promise<number>;

/**
 * Subcommand table, and the extension point for the remaining commands: each one
 * is a single entry here, e.g.
 *
 *   status: async (settings, runner, report) => (await runStatus(settings, runner, report)).ok ? 0 : 1,
 *
 * The usage line below is derived from this table, so nothing else changes.
 */
export const subcommands: Record<string, Subcommand> = {
  render: async (settings, runner, report) => (await renderConfig(settings, runner, report)).code,
};

export interface CliDeps {
  runner?: CommandRunner;
  report?: Reporter;
  env?: Record<string, string | undefined>;
}

export async function runCli(args: string[], deps: CliDeps = {}): Promise<number> {
  const report = deps.report ?? consoleReporter;
  const [name] = args;
  const subcommand = name === undefined ? undefined : subcommands[name];
  if (subcommand === undefined) {
    report.err(
      name === undefined ? "Error: no subcommand given." : `Error: unknown subcommand '${name}'.`,
    );
    report.err(`Usage: mihomo <${Object.keys(subcommands).join("|")}>`);
    return 1;
  }

  const settings = loadSettings(deps.env ?? Deno.env.toObject());
  const runner = deps.runner ?? new RealCommandRunner();
  return await subcommand(settings, runner, report);
}
