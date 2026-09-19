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

`<vault>/sources/<book>/<chapter>.md`, written in the source's language:

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

## § 记录
### §1 哲学的两种名声
<one to three lines: the map, not the argument>

## 条目 · 术语表
<dates, names, metaphors — lookups>
```

`### §n` headings quote the source's own numbering and titles, and freeze once written: they are the anchors every other page cites. A section with nothing map-worthy still gets its heading and one line.

Gloss each key term once on first use — `维柯 (Vico)`. Claims stay out: what the chapter *implies* belongs on a promoted page, tagged `[reconstruction]`.

Quotes follow [EVIDENCE](../EVIDENCE.md), and the count of checked spans goes into `quotes_check:` in the same run that writes them.

Completion: the map covers every section of the chapter; anchors match the source's numbering; the count matches the page's `>` blocks.

## Put the candidate list to the human

Two to five items. Each line names the page (new, or existing and to be updated), the type it would take, and why. Include the material that should *not* become a page — a date, an example, a restatement — so the human can see the bar being applied.

Use the harness's question tool when one is available, then stop and wait. Nothing gets promoted from a list the human has not answered.

## Then, in the same session

Write or update the pages the human approved ([TYPES](../TYPES.md)), and refresh the book hub's inventory so `books/<book>.md` stays the one list of what this book produced.
