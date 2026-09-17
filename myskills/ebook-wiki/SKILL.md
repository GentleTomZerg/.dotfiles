---
name: ebook-wiki
description: Compile EPUB/PDF readings into an Obsidian wiki via ebook-mcp. Use when setting up reading/<book>/, ingesting a chapter, asking across chapters, or linting the wiki.
---

# Ebook Wiki

Compile, don't retrieve. Read each source once, compile it into a persistent interlinked wiki, then answer from the wiki.

`raw/` is immutable and agent-never-writes. `wiki/` is agent-owned and human-read. The human curates sources and asks questions; the agent does the bookkeeping.

## Steps

### 1. Locate or setup the book wiki

Find the vault root (directory containing `.obsidian/`). Work under `reading/<book>/`.

If `reading/<book>/AGENTS.md` is missing, scaffold it. See [SCHEMA](references/SCHEMA.md).

**Completion**: `reading/<book>/` holds `AGENTS.md`, `index.md`, `log.md`, `raw/book-info.md`, and `wiki/` exists. `raw/book-info.md` names the absolute EPUB/PDF path.

### 2. Ingest one chapter

Ingest exactly one chapter per run. Never batch-ingest. Human reads first. See [INGEST](references/INGEST.md).

Flow: human pre-reads → agent reads via `ebook-mcp` → walk section-by-section with the human → write files → update index and log. Never write wiki files before the human confirms the takeaways.

**Completion**: human confirms takeaways for every section; `wiki/sources/<chapter>.md` written; every new concept/person has a `[[link]]`; `index.md` updated; `log.md` appended with `## [YYYY-MM-DD] ingest | <chapter>`.

### 3. Query the wiki

Read `index.md` first, then drill into the linked pages only. Synthesize with `[[citations]]`. See [LANGUAGE](references/LANGUAGE.md) for wording rules.

File valuable answers back: save comparisons, analyses, and discovered connections as new pages under `wiki/` and update `index.md` + `log.md` with a `query` entry.

**Completion**: answer cites the wiki pages used; any reusable synthesis is filed as a page rather than left in chat history.

### 4. Lint the wiki

On request, or when the wiki passes ~10 ingests without a lint. Check: contradictions between pages, stale claims superseded by newer chapters, orphan pages with no inbound links, concepts mentioned but lacking a page, missing cross-references. Then suggest outward: 2-5 new questions to investigate and 2-5 new sources to fetch via web search.

**Completion**: report lists each issue as `page → problem → fix`, plus `questions to investigate` and `sources to fetch`; applied fixes are reflected in `index.md` + a `log.md` `lint` entry.

## References

- [SCHEMA](references/SCHEMA.md) — folder layout, per-book `AGENTS.md` template, `index.md` / `log.md` conventions.
- [INGEST](references/INGEST.md) — chapter ingest checklist and `ebook-mcp` tool mapping.
- [LANGUAGE](references/LANGUAGE.md) — primary-language rule with glosses.
