import { type Document, isMap as isYamlMap, type YAMLMap } from "@eemeli/yaml";
import { isRecord } from "./record.ts";

/**
 * Merge two plain-JS values. Maps merge recursively; arrays and scalars replace
 * wholesale, so an overlay array never appends to the base array.
 */
export function deepMerge(base: unknown, overlay: unknown): unknown {
  if (isRecord(base) && isRecord(overlay)) {
    const out: Record<string, unknown> = { ...base };
    for (const [key, value] of Object.entries(overlay)) {
      out[key] = key in base ? deepMerge(base[key], value) : value;
    }
    return out;
  }
  return overlay;
}

/**
 * Merge plain values into a parsed document's root map, in place. Only the
 * contents of existing nodes are updated, so a template's anchors and `!!merge`
 * tags survive into the rendered file with their meaning intact.
 *
 * A template that is not a mapping has nothing to merge into and is left as it
 * is; `mihomo -t` rejects whatever the emitter produces from it.
 */
export function mergeIntoDocument(doc: Document, source: unknown): void {
  if (isYamlMap(doc.contents)) mergeIntoNode(doc.contents, source);
}

function mergeIntoNode(target: YAMLMap<unknown, unknown>, source: unknown): void {
  if (!isRecord(source)) return;
  // The template ships `proxy-providers: {}`, a flow-style empty map. Filling it
  // while leaving `flow` set emits every merged entry on one line, which Go's
  // YAML parser rejects — so `mihomo -t` fails on an otherwise sound config.
  target.flow = false;
  for (const [key, value] of Object.entries(source)) {
    const existing: unknown = target.get(key, true);
    if (isYamlMap(existing) && isRecord(value)) {
      mergeIntoNode(existing, value);
    } else {
      target.set(key, value);
    }
  }
}
