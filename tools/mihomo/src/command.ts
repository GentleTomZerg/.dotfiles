export interface CommandResult {
  code: number;
  stdout: string;
  stderr: string;
}

export interface CommandOptions {
  /** default "null" */
  stdin?: "inherit" | "null";
  /** default true; false inherits stdout+stderr (for interactive sudo) */
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
    const capture = options.capture ?? true;
    const child = new Deno.Command(command, {
      args,
      stdin: options.stdin ?? "null",
      stdout: capture ? "piped" : "inherit",
      stderr: capture ? "piped" : "inherit",
      cwd: options.cwd,
      env: options.env,
    });
    if (capture) {
      const { code, stdout, stderr } = await child.output();
      return {
        code,
        stdout: new TextDecoder().decode(stdout),
        stderr: new TextDecoder().decode(stderr),
      };
    }
    const status = await child.spawn().status;
    return { code: status.code, stdout: "", stderr: "" };
  }
}
