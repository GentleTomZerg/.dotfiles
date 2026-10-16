import { assertEquals, assertStringIncludes } from "@std/assert";
import { parseDocument } from "@eemeli/yaml";
import { deepMerge, mergeIntoDocument } from "../src/merge.ts";
import { parseYamlPreservingAnchors } from "../src/yaml.ts";

Deno.test("deepMerge merges maps recursively", () => {
  assertEquals(deepMerge({ a: { x: 1 }, b: 1 }, { a: { y: 2 }, c: 3 }), {
    a: { x: 1, y: 2 },
    b: 1,
    c: 3,
  });
});

Deno.test("deepMerge replaces arrays wholesale", () => {
  assertEquals(deepMerge({ a: [1, 2] }, { a: [3] }), { a: [3] });
});

Deno.test("deepMerge replaces scalars", () => {
  assertEquals(deepMerge({ a: 1, b: "x" }, { a: 2 }), { a: 2, b: "x" });
});

Deno.test("deepMerge replaces a map with a scalar or an array", () => {
  assertEquals(deepMerge({ a: { x: 1 } }, { a: 5 }), { a: 5 });
  assertEquals(deepMerge({ a: 5 }, { a: [1] }), { a: [1] });
});

Deno.test("deepMerge does not mutate its inputs", () => {
  const base = { a: { x: 1 } };
  const overlay = { a: { y: 2 } };
  deepMerge(base, overlay);
  assertEquals(base, { a: { x: 1 } });
  assertEquals(overlay, { a: { y: 2 } });
});

/** Read a document back as plain data, resolving merge tags. */
function resolved(text: string): unknown {
  return parseDocument(text, { merge: true }).toJS();
}

Deno.test("mergeIntoDocument merges maps recursively and replaces arrays wholesale", () => {
  const doc = parseYamlPreservingAnchors(`dns:
  enable: true
  fake-ip-filter:
    - "+.lan"
`);

  mergeIntoDocument(doc, {
    dns: {
      enable: false,
      "proxy-server-nameserver": ["https://zone.example.test/api-query"],
      "fake-ip-filter": ["+.stun.example.test"],
    },
    hosts: { "+.example.test": "127.0.0.1" },
  });

  assertEquals(resolved(doc.toString()), {
    dns: {
      enable: false,
      "fake-ip-filter": ["+.stun.example.test"],
      "proxy-server-nameserver": ["https://zone.example.test/api-query"],
    },
    hosts: { "+.example.test": "127.0.0.1" },
  });
});

Deno.test("mergeIntoDocument keeps the template's anchors and merge tags", () => {
  const doc = parseYamlPreservingAnchors(`rule-anchor:
  domain: &domain { type: http, behavior: domain }
rule-providers:
  direct:
    !!merge <<: *domain
    url: "https://example.test/direct.mrs"
`);

  mergeIntoDocument(doc, { "proxy-providers": { airport: { type: "http" } } });

  const text = doc.toString();
  assertStringIncludes(text, "&domain");
  assertStringIncludes(text, "!!merge <<: *domain");
  assertEquals(resolved(text), {
    "rule-anchor": { domain: { type: "http", behavior: "domain" } },
    "rule-providers": {
      direct: { type: "http", behavior: "domain", url: "https://example.test/direct.mrs" },
    },
    "proxy-providers": { airport: { type: "http" } },
  });
});

Deno.test("mergeIntoDocument emits block style when it fills a flow-style empty map", () => {
  const doc = parseYamlPreservingAnchors("proxy-providers: {}\n");

  mergeIntoDocument(doc, { "proxy-providers": { airport: { type: "http" } } });

  assertStringIncludes(doc.toString(), "proxy-providers:\n  airport:");
});
