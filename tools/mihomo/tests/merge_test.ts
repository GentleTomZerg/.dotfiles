import { assertEquals } from "@std/assert";
import { deepMerge } from "../src/merge.ts";

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
