import { type Document, parseDocument } from "@eemeli/yaml";

/** Parse YAML preserving anchors, aliases and `!!merge` tags (merge NOT resolved). */
export function parseYamlPreservingAnchors(text: string): Document {
  return parseDocument(text, { merge: false });
}

/** Emit a Document back to YAML text (anchors/merge tags intact). */
export function emitYaml(doc: Document): string {
  return doc.toString();
}

/** Parse a document to plain JS. `merge:false` keeps `<<` pairs as literal keys. */
export function toPlain(doc: Document): unknown {
  return doc.toJS();
}
