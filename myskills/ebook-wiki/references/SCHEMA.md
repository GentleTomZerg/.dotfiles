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

## The conventions block

`reading/<book>/AGENTS.md` holds the book's conventions and nothing else — the workflow lives in this skill. Its heading follows the book's language: `## 读法` for a Chinese book, `## How to read` for an English one ([LANGUAGE](LANGUAGE.md)). Fill it from the setup interview, not by hand:

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
```

When a friction repeats twice — source page shape, link style, a language gloss — update this block with the human before continuing. Changing the shape of pages already written is a migration: see [MIGRATE](MIGRATE.md).

## index.md convention

Catalog by category, one line per page with a link and a one-line summary:

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
