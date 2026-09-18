# Ingest — one chapter per run

Karpathy's reading order: pass 1 human reads manually, pass 2 agent explains/summarizes, pass 3 Q&A. Never skip to writing.

The page you are about to write is the [spine](SPINE.md) plus the cores named in `reading/<book>/AGENTS.md` `## 读法` (or in the chapter's own `cores:` frontmatter).

## Checklist

0. **Human pre-reads.** Ask the human to read (or skim) the chapter first, or state what they already read. If they have not read it, walk only the first section and stop.
1. **Resolve the chapter.** Read the `chapter_id` from `raw/book-info.md`. For EPUBs the id looks like `OEBPS/Text/Section0001_split_000.xhtml#sigil_toc_id_6`. Never guess ids; list the TOC first when unsure.
2. **Read via ebook-mcp.**
   - EPUB TOC: `ebook-mcp_get_epub_toc`
   - EPUB chapter: `ebook-mcp_get_epub_chapter_markdown`
   - PDF TOC: `ebook-mcp_get_pdf_toc`
   - PDF chapter: `ebook-mcp_get_pdf_chapter_content` (or `ebook-mcp_get_pdf_page_markdown` for page ranges)
3. **Walk section-by-section. No wiki writes in this step.** Present one section at a time: what it argues, the key distinction, one question for the human. Wait for the human's reply before presenting the next section. End with 3 chapter takeaways: core claim, key distinction, tension with earlier chapters. Wait for explicit confirmation on what to emphasize. Writing any wiki file before this confirmation fails the step.
4. **Verify every quote before it is written.** Keep the raw chapter text in hand; for each `[直引]` candidate, split on `……`, move framing and 编注 out of the span, and check each fragment. Record the outcome per the [quote protocol](SPINE.md). Fixes happen here, not in review — a quote that cannot be verified is rewritten or demoted to 转述.
5. **Write the source page** `wiki/sources/<chapter>.md` (only after confirmation): spine blocks in order, then each declared core's slots, then `## 引文核对`.
6. **Propagate.** Update `wiki/00-overview.md`, touch affected `wiki/concepts/*.md` and `wiki/persons/*.md`, create missing ones. Every concept/person mention becomes a `[[link]]`. Links back into the source page target `#§n <节名>` only.
7. **Close the loop.** Update `index.md`, append `log.md` with `## [YYYY-MM-DD] ingest | <chapter> | <chapter_id>`. Then run the structural half of the lint: every `### §n` present, every quote in `## 引文核对`, every inbound anchor resolving.

## Notes

- If the chapter's core slots come out empty, do not pad them. An empty slot is either omitted (per [SPINE](SPINE.md) "Empty slots") or evidence that the book's `## 读法` is wrong — raise the latter with the human and fix the block.
- If the chapter clearly needs a core the book did not declare, propose the override (`cores:` in frontmatter) to the human rather than widening the book default.
- Raw chapter text fetched in step 2 is working material, not a wiki file. Do not save it under `wiki/`.
