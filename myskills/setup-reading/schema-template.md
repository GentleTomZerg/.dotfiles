# Reading wiki — schema

This file is authoritative for every session in this vault. The reading skills read it and follow it. Edit it directly; the skills point here instead of restating the conventions.

## Who does what

The human reads and decides. You write and maintain.

- **Pass 1 is the human's.** They read the source. You never substitute a summary for that read, and you never compress a unit whose `pass1` is not `read`.
- **Pass 2 is `/skill:ingest`** — you compress a unit into pages, with the human's emphasis.
- **Pass 3 is `/skill:query`** — the human argues with you about what they read; you answer from the wiki and the sources, and you file the good answers back.
- **`/skill:test-me`** proves the human knows it. **`/skill:synthesize`** turns several sources into a position. **`/skill:lint-wiki`** keeps the wiki healthy.
- **Decisions are the human's.** Positions, adjudications, and scope calls are theirs to make; you draft, present, and record. You never invent a resolution to fill a gap.

Karpathy's frame, which this vault follows: the raw sources are the source of truth, the wiki is the compiled artifact, and this file is the schema that makes you a wiki maintainer rather than a chatbot. Obsidian is the IDE; you are the programmer; the wiki is the codebase.

## Layout

```
raw/                    immutable sources — clipped articles, extracted chapters, pasted quotes
wiki/summaries/         one page per source unit
wiki/entities/          people, works, projects, named things that recur
wiki/concepts/          one page per idea
wiki/comparisons/       two or more sources on one topic, side by side
wiki/syntheses/         the human's position on a contested topic
templates/              one page skeleton per type — copy it when you create a page
index.md                content catalog — every page, one line each
log.md                  chronological record, append-only
intent.md               what this reading is for (or intent/<project>.md)
inbox.md                questions captured without an agent
```

## Page types

| Type | Holds | Answers |
|---|---|---|
| **summary** | what one source unit says, compressed, in the source's own terms | *what does it claim?* |
| **entity** | one person, work, project, or named thing that recurs | *who or what is this?* |
| **concept** | one idea, integrated across every source that touches it | *what is true here?* |
| **comparison** | two or more sources on one topic: positions, the arguments behind them, where they collide | *where do they disagree?* |
| **synthesis** | the human's position, with the cases it covers and the case that breaks it | *what do I hold?* |

A **concept page** carries the disagreement rather than hiding it: when a new source contradicts an existing claim, the page keeps both, attributes both, and marks the contradiction in place. Nothing is silently overwritten.

Skeletons for every type live in `templates/`. Copy the type's skeleton when you create a page, and trim the sections that carry nothing.

## Frontmatter

```yaml
---
type: concept            # summary | entity | concept | comparison | synthesis
sources: ["[[clean-code-ch07]]"]   # summary pages this page draws on
pass1: read 2026-09-21   # summary pages only — the human's read of this unit
tested: 2026-09-21       # last test session touching this page
confidence: solid        # solid | shaky | unlearned
status: decided          # synthesis pages only — decided | open
---
```

## The human's words

Every concept and synthesis page carries an `## In my words` line: the human's own formulation of the idea, in their phrasing. It is promoted there only by a **solid** test pass. Until then the page has no such line, and the agent's prose stands in as scaffolding, plainly marked as pending.

This is the one place the human writes the wiki, and it is what keeps the vault their knowledge rather than a book report. Their sentence, not the source's, is what they will remember.

## Citations

Every claim that came from a source cites it: `([[clean-code-ch07#Locator]])`, where the locator is a page number, section, or paragraph — whatever the source supports. A claim with no citation is either the agent's synthesis (mark it as such) or it does not belong on the page.

## Links

Pages link each other with `[[wikilinks]]`, at least two per page. A link to a page that does not exist yet is a **red link** — a concept worth its own page. Red links are the wiki's own backlog, and `/skill:lint-wiki` collects them.

## Open questions

An idea the vault cannot yet settle lives as an `## Open questions` bullet **on the page it hangs off**, never in a separate tracker. Each bullet says what would answer it: another source, a passage to re-read, or a decision the human has to make. `/skill:lint-wiki` aggregates them and sweeps `inbox.md`.

A question that needs material outside the vault is a job for `/skill:research`, and its findings file back as pages.

## Tests

A `## Tests` section holds one prompt per thing the human must be able to produce. Each test names its `must include` elements — the load-bearing parts, written down so grading has something to check.

```markdown
### T1 — reproduce
**Prompt:** <asked cold: no page, no source>
**Must include:** (a) … (b) … (c) …
**Tested:** 2026-09-22 → solid | partial | not-yet
**Confidence:** solid | shaky | unlearned
```

The three forms are **reproduce**, **reconstruct**, and **adjudicate**. `/skill:test-me` owns the loop, the grading, and which form a page gets.

## index.md

Content-oriented, updated on every ingest — a catalog, one line per page:

```markdown
- [[clean-code-ch07]] — error handling by exception, with context; pass1 read
```

## log.md

Chronological, append-only, one line per event, with a parseable prefix so `grep "^## \[" log.md | tail -5` works:

```markdown
## [2026-09-21] ingest | Clean Code ch07
## [2026-09-22] query | why does Ousterhout call exceptions "class-level"?
## [2026-09-22] test | error-handling — 2 solid, 1 partial
## [2026-09-23] lint | 4 findings
```

## Invariants

1. Pass 1 is the human's — record it; never replace it.
2. `raw/` is immutable. Read it; never edit it.
3. No page without a source behind it.
4. Contradictions are flagged in place, never overwritten.
5. Candidate questions and candidate tests are proposals; only accepted ones become work.
6. An idea is known when the human can reproduce it from memory; familiarity is not knowledge.
7. Every session ends with a write and a log line.
