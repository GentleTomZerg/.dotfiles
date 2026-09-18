# Spine — the fixed part of every source page

Every `wiki/sources/<chapter>.md` has these blocks, in this order, whatever cores the book declares.

1. **Identity** — frontmatter (`publish:`, `cores:` only when overriding the book) plus a `- source:` line wikilinking the book record and naming the chapter id: `- source: [[raw/book-info|来源]] · <chapter_id>`. Never a file path — paths are per-machine, and the page outlives the machine.
2. **How to read** — one line saying how to use this page ("Skeleton first, then descend into whichever argument you need").
3. **§ Record** — `### §n <section title>` for every section of the chapter, one to three lines each. **This is the anchor contract.**
4. **Cores** — in the order the book declared them. See [cores](cores/).
5. **Key quotes** — verbatim, each with a source line. Required for `argue` and `trace`; optional otherwise.
6. **Open questions** — every `[mine]` in the page is claimed here.
7. **Quote check** — the verification table for every verbatim quote.

Block names and table headers follow the book's language — see [LANGUAGE](LANGUAGE.md).

## Anchor contract

`### §n <section title>` is the only anchor other pages may link to.

- Headings match the book's own section numbering and titles, in the book's language, quoted rather than translated.
- Section numbers are the *page's* decomposition of the chapter; once written they are **frozen**. Renaming one breaks inbound links.
- Every link from `wiki/concepts/`, `wiki/persons/`, `index.md`, `00-overview.md` targets `#§n <section title>` — never a core block anchor. Block anchors (`#Argument 3`) are for navigation inside the page only, where a re-refine rewrites both sides together.

## Quote protocol

The rule that makes the wiki trustworthy: **a quote is verbatim if and only if it appears as `✓` in `## Quote check`.** Everything else is a paraphrase, written as ordinary prose with no `>` block.

**Location.** `〈Chapter〉§section`, plus `p.N` when the source is a PDF — ebook-mcp returns PDF at page granularity, and a page number is stable within one file. Never file paths, never sigils. The retrieval key is the first 8 characters of the quoted sentence: search that in any reader and you land on the passage. **The key must be unique within its chapter** — at ingest you hold the whole chapter, so extend the key until the search is unambiguous. The chapter is the right scope, because the location already names it.

**Before writing, verify each quote against the raw chapter text:**

1. Check the **whole span** first. Found verbatim, it is `✓` with 0 elisions — regardless of any `…` inside it, because an ellipsis belonging to the source's own phrasing (`"liberty from …"`) is part of the quote, not an elision.
2. Only if the whole span misses, split on elision markers (`……`, `...`) and check each surviving fragment; *elisions* = the number of split boundaries. Prefer rewriting a heavy span as several short verbatim quotes — a short exact span carries no count and no ambiguity.
3. Move editorial apparatus out of the quoted span:
   - framing the agent added (`Herzen's question:`, `the Eichmann case:`) belongs in the ground's label, not inside the quote;
   - editorial notes (`(ed. note: …)`) go outside the `>` block as source-line annotations.
4. Normalize for matching whitespace and full-width/half-width width only. **Wording and punctuation marks are never normalized** — quote marks stay exactly as printed. Rewriting `“”` as `''` to nest inside a quote block is a transcription defect, and the check flags it as `⚠ not found`.

**Failure classes** — a `⚠` must say which:

| Mark | Meaning |
|---|---|
| `✓` | every fragment found verbatim |
| `⚠ splice` | the span joins text that is not contiguous in the source and was not marked with `…` |
| `⚠ framing` | the span contains the agent's own framing rather than the source's words |
| `⚠ not found` | a fragment cannot be found at all |

A quote that fails verification is **rewritten**, not shipped: fix the elision and scope, or demote it to a paraphrase. Never carry a quote forward from memory or an earlier draft.

**Table format** (`## Quote check`):

The first column is a retrieval index, not just an audit trail — no portable deep link into an EPUB exists, so this is how a human reaches the passage on any machine.

```md
| key | source | elisions | result |
|---|---|---|---|
| The most popu | §verificationism | 0 | ✓ |
| If I say “all | §verificationism | 1 | ✓ |
| But the egg i | §pluralism | 2 | ✓ |
| This pink (in | §verificationism | 0 | ⚠ splice (two separate sentences; … added) |
```

A page with no verbatim quotes writes `(no verbatim quotes)` under the heading and keeps the heading.

## Honesty tags

Every warrant and inference step carries exactly one tag:

- `[stated]` — the source states this outright.
- `[reconstruction]` — the source implies it; the step is the agent's reconstruction.
- `[mine]` — the step is the agent's own addition, beyond the source.

Every `[mine]` additionally appears as a `> [!warning] My own addition` block at the point of use **and** is claimed in `## Open questions`, so a reader can see exactly where the source stopped and the agent started.

## Empty slots

A core slot with no material is **omitted**, never padded with filler. Only two spine blocks are unconditional: `### §n` record and `## Quote check`.
