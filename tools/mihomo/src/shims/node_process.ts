// @eemeli/yaml imports these two names from node:process. The real binding
// reads env.LOG_TOKENS (a debug hook) on every parse, which needs
// --allow-env. This shim keeps the pure test suite permission-free.
export const env: Record<string, string | undefined> = {};
export function emitWarning(warning: string | Error, options?: { type?: string }): void {
  if (options?.type === "DeprecationWarning") return;
  console.warn(warning);
}
