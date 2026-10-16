export interface Reporter {
  /** Informational output. */
  out(line: string): void;
  /** Problems and warnings. */
  err(line: string): void;
}

export const consoleReporter: Reporter = {
  out: (line: string) => console.log(line),
  err: (line: string) => console.error(line),
};
