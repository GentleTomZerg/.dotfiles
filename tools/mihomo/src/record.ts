/**
 * True for a plain mapping: an object that is neither `null` nor an array. The
 * one guard the merge, the lifting rules and the parity comparator all share.
 */
export function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
