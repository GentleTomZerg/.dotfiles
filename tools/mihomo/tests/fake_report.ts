import type { Reporter } from "../src/report.ts";

/** A Reporter that records the two output channels so tests can assert the split. */
export function recordingReporter(): { report: Reporter; out: string[]; err: string[] } {
  const out: string[] = [];
  const err: string[] = [];
  return {
    report: { out: (line: string) => out.push(line), err: (line: string) => err.push(line) },
    out,
    err,
  };
}
