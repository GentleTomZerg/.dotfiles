export interface CommandResult {
  code: number;
  stdout: string;
  stderr: string;
}

/** How one child stream is wired up. */
export type StreamMode = "capture" | "inherit" | "null";

export interface CommandOptions {
  /** default "null" */
  stdin?: "inherit" | "null";
  /**
   * Per-stream handling. "capture" pipes the stream and returns its contents;
   * "inherit" passes the parent's stream through (interactive prompts);
   * "null" attaches it to /dev/null, so a backgrounded child cannot hold a pipe
   * open and keep the wait hanging.
   */
  stdout?: StreamMode;
  stderr?: StreamMode;
  /** Shorthand: `false` inherits stdout+stderr. A per-stream mode overrides it. */
  capture?: boolean;
  cwd?: string;
  env?: Record<string, string>;
}

export interface CommandRunner {
  run(command: string, args: string[], options?: CommandOptions): Promise<CommandResult>;
}

/** Production runner. The only place in the tool that touches `Deno.Command`. */
export class RealCommandRunner implements CommandRunner {
  async run(command: string, args: string[], options: CommandOptions = {}): Promise<CommandResult> {
    const fallback: StreamMode = (options.capture ?? true) ? "capture" : "inherit";
    const stdout = options.stdout ?? fallback;
    const stderr = options.stderr ?? fallback;
    const child = new Deno.Command(command, {
      args,
      stdin: options.stdin ?? "null",
      stdout: toDenoStdio(stdout),
      stderr: toDenoStdio(stderr),
      cwd: options.cwd,
      env: options.env,
    }).spawn();
    const [status, out, err] = await Promise.all([
      child.status,
      stdout === "capture" ? readStream(child.stdout) : Promise.resolve(""),
      stderr === "capture" ? readStream(child.stderr) : Promise.resolve(""),
    ]);
    return { code: status.code, stdout: out, stderr: err };
  }
}

function toDenoStdio(mode: StreamMode): "piped" | "inherit" | "null" {
  return mode === "capture" ? "piped" : mode;
}

/** Drain a piped stream so a child writing more than a pipe buffer cannot block. */
function readStream(stream: ReadableStream<Uint8Array>): Promise<string> {
  return new Response(stream).text();
}
