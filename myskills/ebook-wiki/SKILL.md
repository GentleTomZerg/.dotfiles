---
name: ebook-wiki
description: "Compile EPUB/PDF readings into an Obsidian wiki via ebook-mcp: a shared spine plus per-book cores (argue / explain / trace / record). Use when setting up reading/<book>/, ingesting a chapter, asking across chapters, linting the wiki, or reshaping a book already ingested."
---

# Ebook Wiki

Compile, don't retrieve: read each source once, compile it into a persistent interlinked wiki, then answer from the wiki.

`raw/` is immutable; the agent writes only under `wiki/`. The human curates sources and asks questions; the agent does the bookkeeping.

A query reads the wiki and nothing else. That is the point, and it is also the bet: `raw/` is opened once, at ingest, so a misquote or a misread conclusion entering the wiki becomes authority and is never checked again. The quote check and the honesty tags are what buy the right to stop re-reading. When the wiki is silent or suspected wrong, a query may open **that one chapter** as a declared exception — and the run that opens it also closes the gap (step 3).

Every source page has the same **spine**. What varies is the **core** — the **promise** the page owes you after reading. Cores are declared once per book from what the reading is *for*, not from the book's genre; a single book may declare several, and one chapter may override them ([SPINE](references/SPINE.md), [cores](references/cores/)).

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
4. On every later run, read that block first, then load [SPINE](references/SPINE.md) plus the cores it names. A chapter's shape is its own `cores:` frontmatter, confirmed at write time (step 2); `cores: []` is spine only.

**Completion**: `reading/<book>/` holds `AGENTS.md` with the conventions block filled, `index.md`, `log.md`, `raw/book-info.md` carrying the file identity and the chapter list, and `wiki/`.

### 2. Ingest one chapter

One chapter per run; the human reads it first. Resolve the `chapter_id` from `raw/book-info.md` — list the TOC when unsure, never guess an id. Fetch the chapter with ebook-mcp: `ebook-mcp_get_epub_toc` + `ebook-mcp_get_epub_chapter_markdown`, or `ebook-mcp_get_pdf_toc` + `ebook-mcp_get_pdf_chapter_content` (`ebook-mcp_get_pdf_page_markdown` for page ranges).

Open by declaring the pace — `Pace: per-section` (the `pace:` default recorded in `AGENTS.md`), which the human overrides with one word (`chapter` to batch instead).

Then walk the chapter, **writing no wiki files yet**. Per-section: for each section, what it argues, the key distinction, one question for the human — and wait for their reply before presenting the next. Per-chapter: the same walk, with the questions held back into one batch at the end. Either way, close with three takeaways — core claim, key distinction, tension with earlier chapters — and with a proposed shape for **this** chapter, since you now know what the chapter is and have not yet written a file: which cores, and why, in one line.

> This chapter is a proof chain → `argue`, plus `record` for the notation.

Wait for explicit confirmation on what to emphasise *and* on the shape, and write the agreed cores into the chapter's `cores:` frontmatter. The book's declaration in `AGENTS.md` is the default; the chapter is where it is confirmed against what the chapter turned out to be.

Then verify every quote against the raw text ([quote protocol](references/SPINE.md)), and only then write `wiki/sources/<chapter>.md`, refresh `00-overview.md`, and touch or create the `concepts/` and `persons/` pages it needs.

**Completion**: human confirmed the takeaways for every section and the chapter's shape; `wiki/sources/<chapter>.md` carries the spine plus the chapter's cores; every verbatim quote is `✓` in `## Quote check`; every new concept and person has a `[[link]]`; `index.md` updated; `log.md` appended; the structural pass of step 4 clean.

### 3. Query the wiki

Read `index.md` first, then drill into the linked pages only. Link into a source page by **section anchor** — `[[wiki/sources/<chapter>#§8 多元论]]`, never a core-block anchor — and cite every page you use. See [LANGUAGE](references/LANGUAGE.md) for wording.

The answer takes the shape the question needs — prose, a comparison table, a Marp deck, a chart — and is filed under `wiki/` either way.

When the wiki is silent or suspected wrong, opening that one chapter via the `chapter_id` in `raw/book-info.md` is a declared exception, not a habit: the same run closes the gap — fix the page, and append a `fallback` entry to `log.md` naming what was missing.

File valuable answers back: a comparison, an analysis, a discovered connection becomes a new page under `wiki/`, with `index.md` and `log.md` updated.

**Completion**: the answer cites the wiki pages it draws on; every chapter opened as an exception is reflected in both a page fix and a `log.md` entry; reusable synthesis is filed as a page rather than left in chat.

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
- [MIGRATE](references/MIGRATE.md) — the procedure that keeps `#§n` anchors resolving. Open it before changing a core's shape, adding or reordering a spine block, or revising a book's conventions block once pages are written.
