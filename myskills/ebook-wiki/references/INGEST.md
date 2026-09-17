# Ingest — one chapter per run

Karpathy's reading order: pass 1 human reads manually, pass 2 agent explains/summarizes, pass 3 Q&A. Never skip to writing.

## Checklist

0. **Human pre-reads.** Ask the human to read (or skim) the chapter first, or state what they already read. If they have not read it, walk only the first section and stop.
1. **Resolve the chapter.** Read the `chapter_id` from `raw/book-info.md`. For EPUBs the id looks like `OEBPS/Text/Section0001_split_000.xhtml#sigil_toc_id_6`. Never guess ids; list the TOC first when unsure.
2. **Read via ebook-mcp.**
   - EPUB TOC: `ebook-mcp_get_epub_toc`
   - EPUB chapter: `ebook-mcp_get_epub_chapter_markdown`
   - PDF TOC: `ebook-mcp_get_pdf_toc`
   - PDF chapter: `ebook-mcp_get_pdf_chapter_content` (or `ebook-mcp_get_pdf_page_markdown` for page ranges)
3. **Walk section-by-section. No wiki writes in this step.** Present one section at a time: what it argues, the key distinction, one question for the human. Wait for the human's reply before presenting the next section. End with 3 chapter takeaways: core claim, key distinction, tension with earlier chapters. Wait for explicit confirmation on what to emphasize. Writing any wiki file before this confirmation fails the step.
4. **Write the source page** `wiki/sources/<chapter>.md` (only after confirmation):
   - 摘要 (argument in the human's own words, 3-8 bullets)
   - 论证重构 (premises → conclusion, numbered)
   - 金句摘录 (2-5 short quotes with location)
   - 疑问 (1-3 open questions)
5. **Propagate.** Update `wiki/00-overview.md`, touch affected `wiki/concepts/*.md` and `wiki/persons/*.md`, create missing ones. Every concept/person mention becomes a `[[link]]`.
6. **Close the loop.** Update `index.md`, append `log.md` with `## [YYYY-MM-DD] ingest | <chapter> | <chapter_id>`.

## Source page template

```md
# <chapter>

- source: `raw/book-info.md` + `<chapter_id>`
- status: ingested YYYY-MM-DD

## 摘要
- ...

## 论证重构
1. ...

## 金句
- "..." 

## 疑问
- ...
```
