import type { CommandResult, CommandRunner } from "./command.ts";
import type { Settings } from "./config.ts";
import { mergeIntoDocument } from "./merge.ts";
import type { Reporter } from "./report.ts";
import { type LoadedProvider, locateProviders, type Selection, selectTweaks } from "./tweaks.ts";
import { emitYaml, parseYamlPreservingAnchors, toPlain } from "./yaml.ts";

export interface RenderResult {
  code: number;
  runtimePath: string;
  selection: Selection;
}

/**
 * File access, injected so the render tests run without permissions and never
 * touch the live config directory.
 */
export type ReadFile = (path: string) => Promise<string>;
export type WriteFile = (path: string, data: string) => Promise<void>;
export type RemoveFile = (path: string) => Promise<void>;

/**
 * Render the runtime config: the template, then providers.yaml, then the lifted
 * provider overlay, so the overlay wins. The generated overlay is written next
 * to the result, and the result is discarded unless `mihomo -t` accepts it.
 *
 * Every path comes from `settings`, which derives the config directory from the
 * environment or home only — never from this tool's own location.
 */
export async function renderConfig(
  settings: Settings,
  runner: CommandRunner,
  report: Reporter,
  readFile: ReadFile = (path) => Deno.readTextFile(path),
  writeFile: WriteFile = (path, data) => Deno.writeTextFile(path, data),
  removeFile: RemoveFile = removeIfPresent,
): Promise<RenderResult> {
  const nothingLifted: Selection = selectTweaks([]);

  let providersText: string;
  try {
    providersText = await readFile(settings.providersPath);
  } catch {
    report.err(`Error: Providers file not found at ${settings.providersPath}`);
    return failure(settings, nothingLifted);
  }

  const providers = toPlain(parseYamlPreservingAnchors(providersText));
  const { refs, noPath } = locateProviders(providers, settings.configDir);
  for (const name of noPath) {
    report.err(`Warning: proxy-provider '${name}' sets no path:, so its cache cannot be located`);
    report.err("         and its dns: is not lifted.");
  }

  const loaded: LoadedProvider[] = [];
  for (const ref of refs) {
    let text: string;
    try {
      text = await readFile(ref.path);
    } catch {
      continue; // Not fetched yet: the providers.yaml fallback still covers it.
    }
    const doc = toPlain(parseYamlPreservingAnchors(text));
    if (!carriesDns(doc)) continue;
    loaded.push({ name: ref.name, path: ref.path, doc });
  }
  const selection = selectTweaks(loaded);
  warnAboutSelection(selection, report);

  const overlay = parseYamlPreservingAnchors("{}");
  mergeIntoDocument(overlay, selection.overlay);
  try {
    await writeFile(settings.tweaksPath, emitYaml(overlay));
  } catch {
    report.err(`Error: Failed to write provider tweaks to ${settings.tweaksPath}.`);
    return failure(settings, selection);
  }

  reportLiftedResolvers(selection, providers, report);

  let templateText: string;
  try {
    templateText = await readFile(settings.templatePath);
  } catch {
    report.err(`Error: Template file not found at ${settings.templatePath}`);
    return failure(settings, selection);
  }

  const runtime = parseYamlPreservingAnchors(templateText);
  mergeIntoDocument(runtime, providers);
  mergeIntoDocument(runtime, selection.overlay);
  try {
    await writeFile(settings.runtimePath, emitYaml(runtime));
  } catch {
    report.err("Error: Failed to render runtime config.");
    await discard(removeFile, settings.runtimePath);
    return failure(settings, selection);
  }

  // `mihomo -t` parses the whole config, so a malformed lifted dns: (invalid YAML,
  // a wrong type, a field the core rejects) is caught here rather than at start.
  // It does NOT check that the resolvers answer: an unresolvable
  // proxy-server-nameserver host still passes `-t` and only fails at dial time.
  const tested = await runner.run("mihomo", [
    "-t",
    "-d",
    settings.configDir,
    "-f",
    settings.runtimePath,
  ]);
  if (tested.code !== 0) {
    report.err("Error: rendered config failed 'mihomo -t'; not starting.");
    for (const line of validatorLines(tested)) report.err(line);
    await discard(removeFile, settings.runtimePath);
    return failure(settings, selection);
  }

  report.out(`Runtime config written to ${settings.runtimePath}`);
  return { code: 0, runtimePath: settings.runtimePath, selection };
}

function failure(settings: Settings, selection: Selection): RenderResult {
  return { code: 1, runtimePath: settings.runtimePath, selection };
}

/** `rm -f`: a missing file is fine, anything else is the caller's problem. */
async function removeIfPresent(path: string): Promise<void> {
  try {
    await Deno.remove(path);
  } catch (error) {
    if (!(error instanceof Deno.errors.NotFound)) throw error;
  }
}

/** `has("dns")`: only a cache that ships a dns: block is worth lifting from. */
function carriesDns(doc: unknown): boolean {
  if (doc === null || typeof doc !== "object" || Array.isArray(doc)) return false;
  return (doc as Record<string, unknown>)["dns"] != null;
}

/**
 * Both warnings are only reported for a cache that contributed, so
 * `selection.sourceName` is set whenever they are reached.
 */
function warnAboutSelection(selection: Selection, report: Reporter): void {
  if (selection.state === "multi") {
    report.err("Warning: more than one proxy-provider ships a dns: block, and the multi-provider");
    report.err(`         policy is not designed yet. Using ${selection.sourceName}, ignoring:`);
    for (const name of selection.ignoredNames) report.err(`           ${name}`);
  }
  if (selection.skipped.length > 0) {
    report.err(`Warning: skipping circular DNS resolver(s) from ${selection.sourceName},`);
    report.err("         which would need the very proxy they resolve for:");
    for (const resolver of selection.skipped) report.err(`           ${resolver}`);
  }
}

/**
 * The generated overlay silently overrides the providers.yaml fallback, so this
 * is the only place that difference becomes visible.
 */
function reportLiftedResolvers(selection: Selection, providers: unknown, report: Reporter): void {
  if (selection.applied.length === 0) return;
  report.out(`render: node DNS from ${selection.sourceName}:`);
  for (const resolver of selection.applied) report.out(`          ${resolver}`);
  if (!sameResolvers(selection.applied, fallbackResolvers(providers))) {
    report.err("render: NOTE - that differs from the dns: fallback in providers.yaml.");
    report.err("        Update it so a machine with no cache yet still works.");
  }
}

function fallbackResolvers(providers: unknown): string[] {
  const dns = (providers as Record<string, unknown> | undefined)?.["dns"];
  const resolvers = (dns as Record<string, unknown> | undefined)?.["proxy-server-nameserver"];
  return Array.isArray(resolvers) ? resolvers.map(String) : [];
}

function sameResolvers(left: string[], right: string[]): boolean {
  const a = [...left].sort();
  const b = [...right].sort();
  return a.length === b.length && a.every((resolver, index) => resolver === b[index]);
}

/** `mihomo -t`'s own output, split into lines so each reaches stderr as printed. */
function validatorLines(result: CommandResult): string[] {
  return [result.stdout, result.stderr]
    .flatMap((chunk) => chunk.split("\n"))
    .map((line) => line.trimEnd())
    .filter((line) => line !== "");
}

/** A cleanup that fails must not mask the error being reported. */
async function discard(removeFile: RemoveFile, path: string): Promise<void> {
  try {
    await removeFile(path);
  } catch {
    // Ignored: the partial file is only a leftover, and the caller already fails.
  }
}
