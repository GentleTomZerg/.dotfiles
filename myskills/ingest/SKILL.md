---
name: ingest
description: Turn one unit of a source — a chapter, a paper, an article — into notes, with your emphasis in the interview. Pass 2 of the reading loop.
disable-model-invocation: true
---

# Ingest

Turn **one unit** of a source — a chapter, a section, a paper, an article — into notes, with the human in the loop.

Pass 2. Pass 1 is theirs.

The contract is deliberately narrow: **take a source, understand it, write down what matters.** Everything vault-specific — where notes live, what they carry, how they are cited — comes from the schema this skill reads, so the same skill works on a different vault or a source that is not a book at all.

Locate the vault and read its schema (`AGENTS.md`). The schema is authoritative for the notes, their frontmatter, citations and the invariants — this skill covers only the process.

## Steps

1. **Check pass 1.** The unit's `pass1` — the reading map's row for the unit, or wherever the schema keeps it — records the human's read. If it is not `read`, say so and record `pass1: not-yet` rather than proceeding as if it were read: compression is not a substitute for the read, and notes written first are scaffolding for the read, not its replacement.

   **Completion:** `pass1` is `read`, or the human has explicitly asked for scaffolding ahead of their read.

2. **Establish the unit.** The human names it. Get the text into reach:

   | Source | How |
   |---|---|
   | EPUB | extract the chapter's XHTML and convert (`pandoc -t markdown`, or unzip and read the XHTML) |
   | PDF | `pdftotext -layout -f <first> -l <last>`, or read a page-clipped excerpt |
   | Web / article | the clipped markdown already in `raw/` |
   | Physical | the human's own quotes and page numbers, treated as the text |

   Record `source`, `unit`, and the `locator` scheme (page, section, paragraph) where the schema says provenance goes. A file in `raw/` is read, never edited.

   **Completion:** you hold the unit's full text and know how you will cite it.

3. **Read it whole, once.** Not skimming for candidates.

   **Completion:** you can state the unit's spine in three sentences without looking.

4. **Draft the candidates — before writing anything, and without telling the human which matter yet.** This is the harvest, and it covers the blind spot a question list cannot: you can see what they had no way to ask about.
   - **The note** — the compression, in the source's terms, and the ladder under it when the unit argues: premises, the load-bearing premise, the conclusion, and what it is a response to.
   - **The ideas it is about** — search the vault first. An idea an existing note already holds is integrated there, never duplicated into a fresh note.
   - **Who and what recur** — people, works, projects, named things the vault will meet again.
   - **Collisions** — search the vault for a *different* position on the same topic. A real disagreement is flagged in place with both attributions, never silently overwritten. Report the search you ran; "I looked for X and found Y" is the value.
   - **Tests** — reproduce / reconstruct / adjudicate, with `must include` filled in. A test whose `must include` you cannot write is a test that cannot be graded; `/skill:wiki-recall` grades them later.
   - **Open questions** — what the unit leaves dangling, and what would answer it.
   - **The map row** — `pass1: read`, the `question` this unit answered for the human, and the locator. The reading map is the only place this unit's read is recorded.

   **Completion:** every category is either populated or explicitly empty.

5. **Interview the human.** Present the candidates as a short list — one line each, no prose selling — and ask which they care about, against the intent. Take their emphasis; drop the rest without arguing. Ask what they noticed while reading, and quote them when they give you their own words.

   This step is the point of the whole skill. You cannot infer what the human wants from the source, and the intent alone is too coarse — the emphasis only exists in their head, and this is where it comes out.

   **Completion:** every candidate is accepted or dropped, and the human has told you what they noticed.

6. **Write, in this order.** Take the skeleton and the locations from the schema, and trim the sections that carry nothing.
   - The **note**, with the human's own words quoted where they gave them.
   - **Existing notes** the unit touches — the new claims join the ones already there rather than starting a fresh note. Contradictions are flagged in place, both attributions.
   - Accepted **tests**, on the notes they test.
   - Accepted **open questions**, on the note each hangs off.
   - The **map row** — `pass1`, `question`, locator.
   - The catalog and the log, as the schema defines them.

   **Completion:** every accepted candidate is written, and the catalog, the log and the map row are updated.

7. **Report the diff and the next move.** What changed, which notes are new, whether a note now carries an unresolved collision, and whether the unit earned a recall session now or the human should read on.

## Judgement

- **Integrate, don't append.** An ingest that adds a section to a note and leaves the rest contradictory has made the vault worse. Update the claims, flag the collision.
- **The source's terms first.** Whatever the field calls the thing, the note uses that word — a compression in the agent's vocabulary is unsearchable later.
- **Nothing is known yet.** What you write is a candidate: the compression, with the human's emphasis. Whether it is knowledge is settled when they say it back (`/skill:wiki-recall`), never here.
- **A unit that yields nothing worth keeping is a finding.** Say so and log it; a vault that grows on every ingest regardless of value is a vault nobody rereads.
