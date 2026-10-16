import type { CommandOptions, CommandResult, CommandRunner } from "../src/command.ts";

/** Scripted answer for one external command invocation. */
export type CommandHandler = (
  command: string,
  args: string[],
  options?: CommandOptions,
) => CommandResult;

export interface RecordedCall {
  command: string;
  args: string[];
  options?: CommandOptions;
}

/** A CommandRunner that records every call and answers from a supplied handler. */
export class FakeCommandRunner implements CommandRunner {
  readonly calls: RecordedCall[] = [];

  constructor(private readonly handler: CommandHandler) {}

  run(command: string, args: string[], options?: CommandOptions): Promise<CommandResult> {
    this.calls.push({ command, args, options });
    return Promise.resolve(this.handler(command, args, options));
  }
}
