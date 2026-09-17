# Schema — per-book wiki layout

Scaffold exactly this tree under the vault root:

```
reading/<book>/
  AGENTS.md          # copy of this skill's conventions, co-evolved per book
  index.md           # content catalog; agent reads first on every query
  log.md             # append-only timeline
  raw/
    book-info.md     # absolute EPUB/PDF path + full chapter_id / TOC list
  wiki/
    00-overview.md   # evolving thesis of the whole book
    sources/         # one file per chapter read: <chapter>.md
    concepts/        # cross-chapter ideas, updated by every ingest
    persons/         # people the book keeps citing
```

## Per-book AGENTS.md template

Copy this into `reading/<book>/AGENTS.md` and fill the bracketed parts:

```md
# LLM Wiki - [<book title>]

## Layers
- raw/: read-only. Source path in raw/book-info.md. Read via ebook-mcp, never edit.
- wiki/: agent-owned markdown. Human reads, agent writes.
- This file: conventions for this book. Evolve with the human.

## Ingest - one chapter per run
1. Read the chapter via ebook-mcp (see INGEST reference in ebook-wiki skill).
2. Discuss 3 takeaways with the human first: core claim / key distinction / tension with earlier chapters.
3. Then write wiki/sources/<chapter>.md, update 00-overview.md, concepts/, persons/, index.md, log.md.
4. One chapter may touch 10-15 wiki files. Keep every cross-reference a [[link]].

## Query
Read index.md first, then the linked pages. Cite with [[links]]. File reusable answers back as new wiki pages.

## Lint
Check contradictions, stale claims, orphans, missing pages, missing links. Then suggest 2-5 new questions and 2-5 new sources to fetch.

## Evolve this file
When a workflow friction repeats twice (e.g. source page shape, link style, language gloss), update this file with the human before continuing.
```

## index.md convention

Catalog by category, one line per page with a link and one-line summary:

```md
# Index - [<book>]
## sources
- [[wiki/sources/第一章|第一章]] — one-line gist
## concepts
- [[wiki/concepts/概念A|概念A]] — one-line gist
## persons
- [[wiki/persons/人物A|人物A]] — one-line gist
```

## log.md convention

Append-only. One heading per event with a parseable prefix:

```md
## [2026-09-17] init | 建库, TOC 共 N 章
## [2026-09-18] ingest | <chapter> | <chapter_id>
## [2026-09-19] query | <question> -> wiki/<page>.md
## [2026-09-20] lint | fixed K links, flagged J contradictions
```

`grep "^## \[" log.md | tail -5` shows the last 5 events.
