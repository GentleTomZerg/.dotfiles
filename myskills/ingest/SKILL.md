---
name: ingest
description: Compress one unit of a source into wiki pages, with your emphasis in the interview. Pass 2 of the reading loop.
disable-model-invocation: true
---

# Ingest

Turn **one unit** of a source — a chapter, a section, a paper, an article — into wiki pages, with the human in the loop.

Pass 2. Pass 1 is theirs.

Locate the vault and read its schema (`AGENTS.md`; the vault root has `index.md`, `log.md`, `wiki/`). The schema is authoritative for page types, frontmatter, citations, links and the invariants — this skill covers only the process.

## Steps

1. **Check pass 1.** The unit's `pass1` records the human's read of it. If it is not `read`, say so and record `pass1: not-yet` rather than proceeding as if it were read: compression is not a substitute for the read, and a summary written first is scaffolding for the read, not its replacement.

   **Completion:** `pass1` is `read`, or the human has explicitly asked for scaffolding ahead of their read.

2. **Establish the unit.** The human names it. Get the text into reach:

   | Source | How |
   |---|---|
   | EPUB | extract the chapter's XHTML and convert (`pandoc -t markdown`, or unzip and read the XHTML) |
   | PDF | `pdftotext -layout -f <first> -l <last>`, or read a page-clipped excerpt |
   | Web / article | the clipped markdown already in `raw/` |
   | Physical | the human's own quotes and page numbers, treated as the text |

   Record `source`, `unit`, and the `locator` scheme (page, section, paragraph) in the summary page's frontmatter. A file in `raw/` is read, never edited.

   **Completion:** you hold the unit's full text and know how you will cite it.

3. **Read it whole, once.** Not skimming for candidates.

   **Completion:** you can state the unit's spine in three sentences without looking.

4. **Draft the candidates — before writing anything, and without telling the human which matter yet.** This is the harvest, and it covers the blind spot a question list cannot: you can see what they had no way to ask about.
   - **The summary** — the compression, in the source's terms.
   - **The argument**, when the unit argues — premises, the load-bearing premise, the conclusion, and what it is a response to. Philosophy lives and dies here.
   - **Concepts** — the ideas the unit is *about*. Search the wiki first: an existing page gets integrated, never duplicated.
   - **Entities** — people, works, projects, named things that recur, or that the vault will meet again.
   - **Collisions** — search the wiki for a *different* position on the same topic. A real disagreement is a contradiction flag plus a comparison page. Report the search you ran; "I looked for X and found Y" is the value.
   - **Tests** — reproduce / reconstruct / adjudicate, with `must include` filled in. A test whose `must include` you cannot write is a test that cannot be graded.
   - **Open questions** — what the unit leaves dangling, and what would answer it.

   **Completion:** every category is either populated or explicitly empty.

5. **Interview the human.** Present the candidates as a short list — one line each, no prose selling — and ask which they care about, against the intent. Take their emphasis; drop the rest without arguing. Ask what they noticed while reading, and quote them when they give you their own words.

   This step is the point of the whole skill. You cannot infer what the human wants from the source, and the intent alone is too coarse — the emphasis only exists in their head, and this is where it comes out.

   **Completion:** every candidate is accepted or dropped, and the human has told you what they noticed.

6. **Write, in this order.** Create each page from its skeleton in `<vault>/templates/`, and trim the sections that carry nothing.
   - The **summary page** (their words quoted where they gave them).
   - **Concept and entity pages** — integrate into what is there; a new source's claim joins the existing claims rather than starting a fresh page. Contradictions are flagged in place with both attributions.
   - A **comparison page** when a collision was accepted.
   - Accepted **tests** on the pages they test.
   - Accepted **open questions** on the page each hangs off.
   - `index.md` — a line per new or changed page.
   - `log.md` — `## [<date>] ingest | <source> <unit>`.

   **Completion:** every accepted candidate is on a page, and both catalog files are updated.

7. **Report the diff and the next move.** What changed, which pages are new, whether a page now has an unresolved collision, and whether the unit earned a test session now or the human should read on.

## Judgement

- **Integrate, don't append.** An ingest that adds a section to a page and leaves the rest contradictory has made the wiki worse. Update the claims, note the collision.
- **The source's terms first.** Whatever the field calls the thing, the summary uses that word — a summary in the agent's vocabulary is unsearchable later.
- **A unit that yields nothing worth keeping is a finding.** Say so and log it; a vault that grows on every ingest regardless of value is a vault nobody rereads.
