---
name: ebook-wiki
description: Compile EPUB/PDF readings into an Obsidian wiki via ebook-mcp. Source pages are a shared spine plus per-book cores (argue / explain / trace / record) declared once at setup. Use when setting up reading/<book>/, ingesting a chapter, asking across chapters, or linting the wiki.
---

# Ebook Wiki

Compile, don't retrieve. Read each source once, compile it into a persistent interlinked wiki, then answer from the wiki.

`raw/` is immutable and agent-never-writes. `wiki/` is agent-owned and human-read. The human curates sources and asks questions; the agent does the bookkeeping.

Every source page has the same **spine**. What varies is the **core** — what the page owes you after reading. Cores are declared once per book from what the reading is *for*, not from the book's genre; a single book may declare several, and one chapter may override them. See [SPINE](references/SPINE.md) and [cores](references/cores/).

| Core | The page lets you… |
|---|---|
| [argue](references/cores/argue.md) | check whether each conclusion holds |
| [explain](references/cores/explain.md) | re-derive how it works and when it breaks |
| [trace](references/cores/trace.md) | follow who did what, in what order, and why |
| [record](references/cores/record.md) | look it up without re-reading |

## Steps

### 1. Locate or set up the book wiki

Find the vault root (directory containing `.obsidian/`). Work under `reading/<book>/`.

If `reading/<book>/AGENTS.md` is missing, scaffold it per [SCHEMA](references/SCHEMA.md), then run the setup interview:

1. Read `raw/book-info.md` and the book's TOC **first**.
2. Ask these three questions, each **with your proposal pre-filled** from what you just read — the human edits, not authors:
   - **读完要能干什么** — 判断它是否成立 / 重新推导它怎么工作 / 不用重读就能查 / 跟清谁在何时做了什么 → cores
   - **证据长什么样** — 逐字引文 / 代码 / 图表与数据 / 事件与人物
   - **哪些东西必须留下** — 结论链 / 机制与不变量 / 数字与定义 / 金句
3. Write the result as the `## 读法` block in `reading/<book>/AGENTS.md`. From then on load only [SPINE](references/SPINE.md) plus the cores that block names.

A chapter declares its own `cores:` in frontmatter only when it departs from the book default. `cores: []` means spine only — use it for a chapter read purely for orientation.

**Completion**: `reading/<book>/` holds `AGENTS.md` (with `## 读法`), `index.md`, `log.md`, `raw/book-info.md`, and `wiki/`. `raw/book-info.md` names the absolute EPUB/PDF path.

### 2. Ingest one chapter

Ingest exactly one chapter per run. Never batch-ingest. Human reads first. See [INGEST](references/INGEST.md).

Flow: human pre-reads → agent reads via `ebook-mcp` → walk section-by-section with the human → verify every quote → write files → update index and log. Never write wiki files before the human confirms the takeaways.

**Completion**: human confirms takeaways for every section; `wiki/sources/<chapter>.md` carries the spine plus every declared core; every verbatim quote is `✓` in `## 引文核对`; every new concept/person has a `[[link]]`; `index.md` updated; `log.md` appended with `## [YYYY-MM-DD] ingest | <chapter>`.

### 3. Query the wiki

Read `index.md` first, then drill into the linked pages only. Synthesize with `[[citations]]`, linking to source pages by **section anchor** (`[[wiki/sources/<chapter>#§8 多元论]]`) — never by core-block anchor. See [LANGUAGE](references/LANGUAGE.md) for wording rules.

File valuable answers back: save comparisons, analyses, and discovered connections as new pages under `wiki/` and update `index.md` + `log.md` with a `query` entry.

**Completion**: answer cites the wiki pages used; any reusable synthesis is filed as a page rather than left in chat history.

### 4. Lint the wiki

On request, or when the wiki passes ~10 ingests without a lint. Two passes:

- **Structure** — spine blocks present and in order; one `### §n` heading per chapter section; every quote present in `## 引文核对`; every declared core's required slots present; every anchor referenced from `concepts/`, `persons/`, `index.md`, `00-overview.md` still resolves.
- **Semantics** — contradictions between pages, stale claims superseded by newer chapters, orphan pages with no inbound links, concepts mentioned but lacking a page, missing cross-references.

Then suggest outward: 2-5 new questions to investigate and 2-5 new sources to fetch via web search.

**Completion**: report lists each issue as `page → problem → fix` (structure issues first), plus `questions to investigate` and `sources to fetch`; applied fixes are reflected in `index.md` + a `log.md` `lint` entry.

## References

- [SPINE](references/SPINE.md) — the fixed part of every source page: § record, anchor contract, quote protocol, honesty tags.
- [cores](references/cores/) — `argue` / `explain` / `trace` / `record`, the varying part.
- [INGEST](references/INGEST.md) — chapter ingest checklist and `ebook-mcp` tool mapping.
- [SCHEMA](references/SCHEMA.md) — folder layout, per-book `AGENTS.md` template, `index.md` / `log.md` conventions.
- [LANGUAGE](references/LANGUAGE.md) — primary-language rule with glosses.
- [MIGRATE](references/MIGRATE.md) — moving an existing book onto a new spine/core shape.
- [examples/argue-example.md](references/examples/argue-example.md) — one real source page, trimmed to the spine plus a single argument block.
