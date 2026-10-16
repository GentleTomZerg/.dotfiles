/**
 * Merge two plain-JS values. Maps merge recursively; arrays and scalars replace
 * wholesale, so an overlay array never appends to the base array.
 */
export function deepMerge(base: unknown, overlay: unknown): unknown {
  if (isMap(base) && isMap(overlay)) {
    const out: Record<string, unknown> = { ...base };
    for (const [key, value] of Object.entries(overlay)) {
      out[key] = key in base ? deepMerge(base[key], value) : value;
    }
    return out;
  }
  return overlay;
}

function isMap(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
