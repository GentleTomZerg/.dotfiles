import type { CommandRunner } from "./command.ts";

/**
 * Platform probe through the command seam, so tests inject "Darwin" or "Linux"
 * instead of reading the real host.
 */
export async function isMacOS(runner: CommandRunner): Promise<boolean> {
  const uname = await runner.run("uname", ["-s"]);
  return uname.code === 0 && uname.stdout.trim() === "Darwin";
}
