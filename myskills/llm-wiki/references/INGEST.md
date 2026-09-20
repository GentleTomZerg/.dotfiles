# Ingest — one source, one run

## Find the source

`raw/<book>/book-info.md` carries the identity that has to survive a change of machine:

```md
- file: <filename.epub>
- search roots: <the directory this machine looks in>
- sha256: <hash>          # so both machines agree they hold the same edition, not a same-named one
- edition: <as printed>
- chapters: <count>

## chapter_id
- <title> | <chapter_id>
```

Write it once per book, from the file itself rather than from memory: `ebook-mcp_get_all_epub_files` / `ebook-mcp_get_all_pdf_files` to find it, `ebook-mcp_get_epub_metadata` / `ebook-mcp_get_pdf_metadata` for the edition, `ebook-mcp_get_epub_toc` / `ebook-mcp_get_pdf_toc` for the chapter list.

Chapter text: `ebook-mcp_get_epub_chapter_markdown` by chapter id; for PDFs `ebook-mcp_get_pdf_chapter_content`, or `ebook-mcp_get_pdf_page_markdown` for a page range. Resolve the id from the chapter list — list the TOC rather than guessing one.

An article or any other source: one file under `sources/<slug>.md`, same shape, no `book-info` record.

## Write the source record

`<vault>/sources/<book>/<chapter>.md`, prose in the source's language. Structural keys stay English, and the vault's `AGENTS.md`, `templates/` and `private/tools/wiki.py` are authoritative for which slots this vault requires; this is the shape the skill seeds:

```md
---
type: source
tags: []
updated: 2026-09-19
quotes_check: 46
publish: true
---
# 哲学的目的
- source: 伯林文集·观念的力量 · OEBPS/…/sigil_toc_id_7

## Gist
<the chapter's main claim in one breath>

## Chain

| step | problem | uses | yields | at | down |
| ---- | ------- | ---- | ------ | -- | ---- |

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

- 概念｜核心主张｜多元论 — 全书骨，须与相对主义分开 — §8 #candidate/concept

## Open

- [mine] <a question this reading produced, with an arrow to what carries it>

## § map

### §1 哲学的两种名声
<one to three lines: the map, not the argument>

## Entries
<dates, names, metaphors — lookups>

## Glossary
<terms this chapter defines and no page holds>
```

`### §n` headings quote the source's own numbering and titles, and freeze once written: they are the anchors every other page cites. A section with nothing map-worthy still gets its heading and one line.

Gloss each key term once on first use — `维柯 (Vico)`. Claims stay out: what the chapter *implies* belongs on a promoted page, tagged `[reconstruction]`.

Quotes follow [EVIDENCE](../EVIDENCE.md), and the count of checked spans goes into `quotes_check:` in the same run that writes them.

Completion: the map covers every section of the chapter; anchors match the source's numbering; the count matches the page's `>` blocks.

## Write the candidates

The chain test decides what may be proposed, and it is the whole of this section: an item belongs in the slot only if removing it breaks the chapter's main claim — the `Gist`, a `Chain` row, or a name the chain cannot be restated without. An item that merely illustrates a row is not a candidate. That is what the `§ map` and `Entries` are for: the background figures, the one-line name-drops and the passing examples stay there, and they never reach the wiki.

Each line carries, in this order: the proposed type, the role, the item, one line of why, the `§` anchor, and the tag.

```md
- 概念｜核心主张｜多元论 — 全书骨，须与相对主义分开 — §8 #candidate/concept
- 人物｜例证｜赫尔岑 — §7 只出场一次，但「创造即一切」是他自己的一条线 — §7 #candidate/person
```

Two to five is a good sign, not a rule. A chapter that yields nothing is a real answer: write the slot's one line — `- 无候选 — 本章只是复述，没有可检索的东西`. Never pad the slot to look productive; a padded slot costs the human a sweep and costs the wiki its shape.

Ingest takes no decisions. Do not promote, refuse, rank or reorder — the sweep is a separate run, and it is the human's ([TYPES](../TYPES.md)).

## Then, in the same session

Write the source record and stop. Tell the human what is staged: this chapter's candidates, tagged and waiting for a sweep. Do not refresh the book hub's inventory here — it lists pages, and pages are born in the sweep.
