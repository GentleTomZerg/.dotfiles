// Differential merge parity against the shell helper's `yq` pipeline.
//
// This is the evidence that lets the old `yq eval-all '... * ...'` merge be
// deleted: it merges the REAL template, providers.yaml and lifted
// provider-tweaks.yaml with both engines and fails if any key, array or scalar
// differs. It reads the live config directory and shells out to `yq`, so it is
// NOT part of the permission-free suite (`deno task test`); run it with
// `deno task parity`.
//
// It never writes to the config directory and never prints a config value: a
// divergence is reported as the list of differing PATHS only. providers.yaml
// carries a subscription token, so values must stay out of all output.
import { parseDocument } from "@eemeli/yaml";
import { RealCommandRunner } from "../src/command.ts";
import { loadSettings } from "../src/config.ts";
import { mergeIntoDocument } from "../src/merge.ts";
import { isRecord } from "../src/record.ts";
import { emitYaml, parseYamlPreservingAnchors, toPlain } from "../src/yaml.ts";

/** The merge the shell helper runs: template * providers * lifted overlay. */
const YQ_MERGE = "select(fileIndex == 0) * select(fileIndex == 1) * select(fileIndex == 2)";

/** Resolve `!!merge` anchors into plain data, the way both engines are read. */
function resolve(text: string): unknown {
  return parseDocument(text, { merge: true }).toJS({});
}

function formatPath(path: string, key: string): string {
  return /^[A-Za-z_][A-Za-z0-9_-]*$/.test(key)
    ? `${path}.${key}`
    : `${path}[${JSON.stringify(key)}]`;
}

/**
 * Paths at which `actual` (the TypeScript merge) differs from `expected` (yq).
 * Only paths cross this function, so a diverging value never reaches output.
 */
function collectDiffs(expected: unknown, actual: unknown, path = "$"): string[] {
  if (Array.isArray(expected) || Array.isArray(actual)) {
    if (!Array.isArray(expected) || !Array.isArray(actual)) return [path];
    const diffs: string[] = [];
    for (let i = 0; i < Math.max(expected.length, actual.length); i++) {
      diffs.push(...collectDiffs(expected[i], actual[i], `${path}[${i}]`));
    }
    return diffs;
  }
  if (isRecord(expected) || isRecord(actual)) {
    if (!isRecord(expected) || !isRecord(actual)) return [path];
    const keys = [...new Set([...Object.keys(expected), ...Object.keys(actual)])].sort();
    return keys.flatMap((key) => collectDiffs(expected[key], actual[key], formatPath(path, key)));
  }
  return Object.is(expected, actual) ? [] : [path];
}

Deno.test("collectDiffs names every differing path and is silent on equal structures", () => {
  const equal = { a: 1, b: [1, 2], c: { d: "x" } };
  if (collectDiffs(equal, structuredClone(equal)).length !== 0) {
    throw new Error("equal structures must produce no differing paths");
  }
  const actual = { a: 1, b: [1, 3], c: { d: "y" } };
  const expected = { ...actual, b: [1, 2], c: { d: "x" }, gone: true };
  const want = ["$.b[1]", "$.c.d", "$.gone"];
  const got = collectDiffs(expected, actual);
  if (got.join("\n") !== want.join("\n")) {
    throw new Error(`expected ${JSON.stringify(want)}, got ${JSON.stringify(got)}`);
  }
});

Deno.test("the TypeScript merge matches yq over the real config", async () => {
  const settings = loadSettings({
    HOME: Deno.env.get("HOME"),
    MIHOMO_CONFIG_PATH: Deno.env.get("MIHOMO_CONFIG_PATH"),
  });

  let template: string;
  let providersText: string;
  let overlayText: string;
  try {
    [template, providersText, overlayText] = await Promise.all([
      Deno.readTextFile(settings.templatePath),
      Deno.readTextFile(settings.providersPath),
      Deno.readTextFile(settings.tweaksPath),
    ]);
  } catch {
    throw new Error(
      `parity needs the real mihomo config at ${settings.configDir} ` +
        `(mihomo.yaml, providers.yaml and the lifted provider-tweaks.yaml)`,
    );
  }

  // The old pipeline, verbatim: template * providers * lifted overlay.
  const runner = new RealCommandRunner();
  const yq = await runner.run("yq", [
    "eval-all",
    YQ_MERGE,
    settings.templatePath,
    settings.providersPath,
    settings.tweaksPath,
  ]);
  if (yq.code !== 0) {
    throw new Error(`yq eval-all failed with exit ${yq.code}: ${yq.stderr.trim()}`);
  }

  // The new pipeline, using the production merge helpers on the same inputs.
  const merged = parseYamlPreservingAnchors(template);
  mergeIntoDocument(merged, toPlain(parseYamlPreservingAnchors(providersText)));
  mergeIntoDocument(merged, toPlain(parseYamlPreservingAnchors(overlayText)));

  const expected = resolve(yq.stdout);
  const actual = resolve(emitYaml(merged));

  if (!isRecord(expected) || Object.keys(expected).length === 0) {
    throw new Error("yq produced no top-level keys; there is nothing to compare");
  }

  const diffs = collectDiffs(expected, actual);
  if (diffs.length > 0) {
    throw new Error(
      `merge parity failed: ${diffs.length} differing path(s):\n  ${diffs.join("\n  ")}`,
    );
  }

  // Anti-tautology guard: the comparator must be sensitive to the real shape,
  // not only to the synthetic fixture above, or "0 differences" means nothing.
  const probe = collectDiffs(expected, {
    ...(actual as Record<string, unknown>),
    __parity_probe__: true,
  });
  if (probe.length === 0) {
    throw new Error("comparator missed a difference in the real structure");
  }

  console.log(
    `parity: 0 differences between mergeIntoDocument and yq ` +
      `over ${Object.keys(expected).length} resolved top-level keys`,
  );
});
