# Read — one source, one run

READ is the human's stage. Its output is a source record: what the text says and where, plus every doubt the reading raised, logged and unanswered.

## Find the source

`raw/<book>/book-info.md` carries the identity that has to survive a change of machine:

- file, search roots, sha256, edition, chapter count, then `chapter_id` rows.

Write it once per book, from the file itself rather than from memory: `ebook-mcp_get_all_epub_files` / `ebook-mcp_get_all_pdf_files` to find it, `ebook-mcp_get_epub_metadata` / `ebook-mcp_get_pdf_metadata` for the edition, `ebook-mcp_get_epub_toc` / `ebook-mcp_get_pdf_toc` for the chapter list.

Chapter text: `ebook-mcp_get_epub_chapter_markdown` by chapter id; for PDFs `ebook-mcp_get_pdf_chapter_content`, or `ebook-mcp_get_pdf_page_markdown` for a page range. Resolve the id from the chapter list — never guess one.

An article or any other source: one file under `sources/<slug>.md`, same shape, no `book-info` record.

## Write the record

`<vault>/sources/<book>/<chapter>.md`, prose in the source's language. Structural keys stay English; the vault's `AGENTS.md` and `templates/` are authoritative for which slots this vault requires. This is the shape the skill seeds:

````md
---
type: source
tags: []
updated: 2026-09-19
quotes_check: 0
publish: true
---
# 哲学的目的

- source: [[raw/观念的力量/book-info|来源]] · OEBPS/…/sigil_toc_id_7

## Gist

<the chapter's main claim in one breath>

## Chain

| step | problem | uses | yields | at | down |
| ---- | ------- | ---- | ------ | -- | ---- |

**Delivers**: <what the chain does not prove>
**Breaks at**: <the row whose warrant is undecided, and what would settle it>

## Produced

```base
filters:
  and:
    - 'sources.contains("sources/<book>/<chapter>")'
views:
  - type: table
    name: 本章产出
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - gist
      - updated
```

## Candidates

<written by CURATE — left empty in this run>

## Questions

- [ ] Q1 open — "为什么 §3 把多元论与相对主义并列？" — §3
- [ ] Q2 open — "赫尔岑为何只在 §7 出场？" — §7

## § map

### §1 <title, quoted from the source>
<one to three lines: the map, not the argument>

## Entries
<dates, names, metaphors — lookups>

## Glossary
<terms this chapter defines and no page holds>
````

`### §n` headings quote the source's own numbering and titles, and freeze once written: they are the anchors every other page cites. A section with nothing map-worthy still gets its heading and one line.

Gloss each key term once on first use — `维柯 (Vico)`. The record speaks about the text, never about the world: what the chapter *implies* belongs on a promoted page, tagged `[reconstruction]`, and never as a verdict here. The record is navigation, so it holds no quotes — verbatim spans live on the page whose claim they support ([EVIDENCE](EVIDENCE.md)), and `quotes_check:` stays `0`.

## The Questions slot

Every doubt the reading raises becomes one row. A row is an Obsidian task, so a Base can find the ones still open:

```md
- [ ] Q3 open — "为什么 §3 把多元论与相对主义并列？" — §3
```

- **Q id** — `Q1`, `Q2`, … within this record, stable and never reused. A `live` copy into `index.md` keeps its id.
- **status** — `open` while the reading is going; EXPLORE rewrites it to `answered`, `dropped`, or `live`.
- **doubt** — the puzzle in the human's words, quoted, one or two lines. Not the answer, and not a topic label.
- **anchor** — `— §n`. When the section is long and the passage narrow, add the retrieval key: `— §7 · 词条名`.
- **resolution** — appended by EXPLORE after `→`. This run writes none.

Rows are written when the doubt is raised, not gathered from memory at the end of the chapter. A doubt that never gets a row is a doubt the wiki will never answer.

Defer by default: log the doubt and keep reading. When the human is genuinely stuck, a side conversation (`/btw`) may unblock them — that answer never enters the vault, and the doubt still becomes an `open` row, because an answer no source was checked against is not knowledge.

The agent retrieves only here: fetch the passage, find a term in the wiki, read back what the human said. The chain, the map and the doubts are the human's reading, and the chain test is not applied in this run.

## Then stop

Write the record and stop. Tell the human which doubts are `open`; do not answer them, and do not promote anything. The next run is EXPLORE.

Completion: the map covers every section of the chapter; the anchors match the source's numbering; every doubt has a row; every `Chain` row names the page it yields.
