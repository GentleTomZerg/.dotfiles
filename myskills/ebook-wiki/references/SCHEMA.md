# Schema — per-book wiki layout

Scaffold exactly this tree under the vault root:

```
reading/<book>/
  AGENTS.md          # this book's conventions, incl. the 读法 / How to read block
  index.md           # content catalog; agent reads first on every query
  log.md             # append-only timeline
  raw/
    book-info.md     # absolute EPUB/PDF path + full chapter_id / TOC list
  wiki/
    00-overview.md   # evolving thesis of the whole book
    assets/<book>/   # only images the human supplied (never EPUB extracts)
    sources/         # one file per chapter read: <chapter>.md
    concepts/        # cross-chapter ideas, updated by every ingest
    persons/         # people the book keeps citing
```

## Per-book AGENTS.md template

Copy this into `reading/<book>/AGENTS.md`; the conventions block is filled in by the setup interview, not by hand. Its heading follows the book's language — `## 读法` for a Chinese book, `## How to read` for an English one ([LANGUAGE](LANGUAGE.md)).

```md
# LLM Wiki - [<book title>]

## Layers
- raw/: read-only. Source path in raw/book-info.md. Read via ebook-mcp, never edit.
- wiki/: agent-owned markdown. Human reads, agent writes.
- This file: conventions for this book. Evolve with the human.

## 读法 / How to read
- cores: [<argue | explain | trace | record>]   # order = order of blocks in the source page
- 读完要能干什么 / what must you be able to do afterwards: <one line from the setup interview>
- 证据长什么样 / what evidence looks like: <逐字引文 / 代码 / 图表与数据 / 事件与人物>
- 哪些东西必须留下 / what must be left behind: <结论链 / 机制与不变量 / 数字与定义 / 金句>

## Ingest - one chapter per run
1. Read the chapter via ebook-mcp (see INGEST reference in ebook-wiki skill).
2. Discuss 3 takeaways with the human first: core claim / key distinction / tension with earlier chapters.
3. Verify every quote against the raw text before writing it (see SPINE reference, quote protocol).
4. Then write wiki/sources/<chapter>.md (spine + declared cores), update 00-overview.md, concepts/, persons/, index.md, log.md.
5. One chapter may touch 10-15 wiki files. Keep every cross-reference a [[link]]; link into source pages by #§n anchor only.

## Query
Read index.md first, then the linked pages. Cite with [[links]]. File reusable answers back as new wiki pages.

## Lint
Structure pass: spine and core slots present, quotes all present in the Quote check table, inbound anchors resolving.
Semantics pass: contradictions, stale claims, orphans, missing pages, missing links.
Then suggest 2-5 new questions and 2-5 new sources to fetch.

## Evolve this file
When a workflow friction repeats twice (e.g. source page shape, link style, language gloss), update this file with the human before continuing. A change of shape for existing pages is a migration: see the MIGRATE reference.
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
## [2026-09-18] refine | <chapter> | section record trimmed, argument blocks expanded
## [2026-09-19] migrate | <chapter> | shape v1 → spine+cores, 8 inbound anchors verified
## [2026-09-19] query | <question> -> wiki/<page>.md
## [2026-09-20] lint | fixed K links, flagged J contradictions
```

`grep "^## \[" log.md | tail -5` shows the last 5 events.
