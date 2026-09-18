---
name: ebook-wiki
description: "Compile EPUB/PDF readings into an Obsidian wiki via ebook-mcp: a shared spine plus per-book cores (argue / explain / trace / record). Use when setting up reading/<book>/, ingesting a chapter, asking across chapters, or linting the wiki."
---

# Ebook Wiki

Compile, don't retrieve: read each source once, compile it into a persistent interlinked wiki, then answer from the wiki.

`raw/` is immutable; the agent writes only under `wiki/`. The human curates sources and asks questions; the agent does the bookkeeping.

Every source page has the same **spine**. What varies is the **core** — what the page owes you after reading. Cores are declared once per book from what the reading is *for*, not from the book's genre; a single book may declare several, and one chapter may override them ([SPINE](references/SPINE.md), [cores](references/cores/)).

| Core | The page lets you… |
|---|---|
| [argue](references/cores/argue.md) | check whether each conclusion holds |
| [explain](references/cores/explain.md) | re-derive how it works and when it breaks |
| [trace](references/cores/trace.md) | follow who did what, in what order, and why |
| [record](references/cores/record.md) | look it up without re-reading |

## Steps

### 1. Locate or set up the book wiki

Find the vault root (the directory holding `.obsidian/`). Work under `reading/<book>/`.

If `reading/<book>/AGENTS.md` is missing, scaffold it per [SCHEMA](references/SCHEMA.md), then run the setup interview:

1. Read `raw/book-info.md` and the book's TOC **first**.
2. Ask these three questions, each **with your proposal pre-filled** from what you just read — the human edits, not authors:
   - **What must you be able to do afterwards?** 读完要能干什么
   - **What does evidence look like?** 证据长什么样
   - **What must be left behind?** 哪些东西必须留下
3. Write the answers into the conventions block of `reading/<book>/AGENTS.md`, whose heading follows the book's language ([LANGUAGE](references/LANGUAGE.md)).
4. On every later run, read that block first, then load [SPINE](references/SPINE.md) plus the cores it names. A chapter departs from the book's cores only through its own `cores:` frontmatter; `cores: []` is spine only.

**Completion**: `reading/<book>/` holds `AGENTS.md` with the conventions block filled, `index.md`, `log.md`, `raw/book-info.md` naming the absolute source path, and `wiki/`.

### 2. Ingest one chapter

One chapter per run; the human reads it first. Resolve the `chapter_id` from `raw/book-info.md` — list the TOC when unsure, never guess an id. Fetch the chapter with ebook-mcp: `ebook-mcp_get_epub_toc` + `ebook-mcp_get_epub_chapter_markdown`, or `ebook-mcp_get_pdf_toc` + `ebook-mcp_get_pdf_chapter_content` (`ebook-mcp_get_pdf_page_markdown` for page ranges).

Walk the chapter section by section, **writing no wiki files yet**: for each section, what it argues, the key distinction, one question for the human — and wait for their reply before presenting the next. Close with three takeaways: core claim, key distinction, tension with earlier chapters. Wait for explicit confirmation on what to emphasise.

Then verify every quote against the raw text ([quote protocol](references/SPINE.md)), and only then write `wiki/sources/<chapter>.md`, refresh `00-overview.md`, and touch or create the `concepts/` and `persons/` pages it needs.

**Completion**: human confirmed the takeaways for every section; `wiki/sources/<chapter>.md` carries the spine plus every declared core; every verbatim quote is `✓` in `## Quote check`; every new concept and person has a `[[link]]`; `index.md` updated; `log.md` appended; the structural pass of step 4 clean.

### 3. Query the wiki

Read `index.md` first, then drill into the linked pages only. Link into a source page by **section anchor** — `[[wiki/sources/<chapter>#§8 多元论]]`, never a core-block anchor — and cite every page you use. See [LANGUAGE](references/LANGUAGE.md) for wording.

File valuable answers back: a comparison, an analysis, a discovered connection becomes a new page under `wiki/`, with `index.md` and `log.md` updated.

**Completion**: the answer cites the wiki pages it draws on; reusable synthesis is filed as a page rather than left in chat.

### 4. Lint the wiki

On request, or when the wiki passes ~10 ingests without one. Two passes:

- **Structure** — spine blocks present and in order; one `### §n` heading per chapter section; every quote present in `## Quote check`; every declared core's required slots present; every anchor referenced from `concepts/`, `persons/`, `index.md`, `00-overview.md` still resolves.
- **Semantics** — contradictions between pages, stale claims superseded by newer chapters, orphan pages with no inbound links, concepts mentioned but lacking a page, missing cross-references.

Then suggest outward: 2-5 new questions to investigate and 2-5 new sources to fetch.

**Completion**: report lists each issue as `page → problem → fix` (structure issues first), plus `questions to investigate` and `sources to fetch`; applied fixes are reflected in `index.md` and a `log.md` `lint` entry.

## References

- [SPINE](references/SPINE.md) — the fixed part of every source page: § record, anchor contract, quote protocol, honesty tags.
- [cores](references/cores/) — `argue` / `explain` / `trace` / `record`, the varying part.
- [SCHEMA](references/SCHEMA.md) — folder layout, the per-book `AGENTS.md` conventions block, `index.md` / `log.md`.
- [LANGUAGE](references/LANGUAGE.md) — the book's language: glosses and the fixed vocabulary's two forms.
- [MIGRATE](references/MIGRATE.md) — moving an existing book or page onto a new shape.
