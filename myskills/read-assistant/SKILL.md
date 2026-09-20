---
name: read-assistant
description: Assist a human's reading of a book chapter, paper or article, and keep the wiki it feeds. Use when reading a chapter or article into the vault, logging a reading doubt, working through a source's open questions, curating candidates, sweeping candidates into knowledge pages, asking what the wiki says, or health-checking the vault.
---

# Read assistant

Reading belongs to the human. The agent keeps the record, tests the doubts, and maintains the wiki. Reading builds understanding, exploration tests it, curation decides what stays, compilation turns what stays into pages, and the wiki answers later questions without a re-read.

## The cycle

| step | stage | who | leaves |
| ---- | ----- | --- | ------ |
| 01 | READ | human | doubts, as `open` rows |
| 02 | EXPLORE | agent, in dialogue | `answered` / `dropped` / `live` |
| 03 | CURATE | human-led | `staged` / `kept` / `empty` |
| 04 | COMPILE | both | `promoted` / `refused` / `left` |
| 05 | QUERY | agent | an answer that cites pages |
| 06 | LINT | agent | `page → problem → fix` |

01–04 happen once per source, in order; 03 and 04 are separate runs from 01–02, because reading wants recall and deciding wants precision. 05 and 06 run whenever a question or a health check arrives.

Four kinds of thing come out of this, and only three are files. A **source record** says what a text says and where. A **candidate** is a tagged line inside it, undecided. A **knowledge page** is born only by promotion. **Synthesis** is a page type, not a stage. [VOCABULARY](references/VOCABULARY.md) holds the vocabulary — it is the language this skill, the vault's `AGENTS.md`, and its pages share.

## Orient

Before any stage: read the vault's `AGENTS.md` (its registry and conventions), then `index.md`. The vault is the directory holding `.obsidian/` — `~/Projects/Obsidian-Vault` unless the human says otherwise. Read [LAYOUT](references/LAYOUT.md) when the vault is new, or when folders, frontmatter or views are in question.

Name the stage in your first message, and do that stage's work only.

Completion: the registry is in context, and you know which types this vault accepts.

## 01 READ — the human reads

The human's stage. Pace, dialogue, and how much gets read at once are theirs to set. The agent retrieves and transcribes: find the source, fetch the chapter, write the record skeleton, and put into it what the human says. It adds no reading of its own.

Doubts are logged, not answered. An answer reached mid-read in a side conversation never enters the vault: it unblocks the reading, and the doubt still becomes an `open` row so EXPLORE can test it against the text.

Read [READ](references/READ.md) for finding a source, the `§` map, the `Chain` table, and the `Questions` row format.

Completion: the record exists with a `§` map covering every section, a `Chain` table whose rows each name the page they yield, and one `open` row per doubt, each with its `§` anchor. The record is navigation — it holds no quotes (`quotes_check: 0`).

## 02 EXPLORE — test the doubts

The agent's stage, one doubt at a time, with the human in dialogue. Take the first `open` row, test it against the text and against the wiki, and close it with the human. Write the closure into that row as soon as it closes — before starting the next. Never batch, and never close a doubt the human has not accepted.

A close is **answered** (a one-line resolution, with its warrant), **dropped** (a one-line reason), or **live** (the same, plus a copy into `index.md` 我在追的). `investigating` is the session's focus and is never written; a run that dies leaves the row `open`, which is the truth.

Read [EXPLORE](references/EXPLORE.md).

Completion: no `open` row remains in this source — every doubt reads `answered`, `dropped`, or `live` with its resolution — and every `live` doubt appears in `index.md`.

## 03 CURATE — decide what survives

A separate run, human-led, and it never touches question status. Each `answered` row faces the chain test: stage it only if removing it breaks the chapter's main claim. The run writes one new artifact — the `Candidates` slot, an export manifest with a line per answered row: **staged** (a candidate line, tagged), **kept** (residue in the source, with its reason), or the chapter's one-line **empty** yield.

No explaining here: the claim, not the case for it. The case is the sweep's business.

Read [CURATE](references/CURATE.md).

Completion: every `answered` row has exactly one manifest line, and every `staged` line carries its type, role, claim, anchor, target page, and warrant.

## 04 COMPILE — turn survivors into pages

With the human, one source at a time: decide every tagged line, then draft what the decisions call for. A line becomes **promoted** (`→ [[page]]` with the date), **refused** (rewritten with its one-line reason and the date), or is **left** tagged. Refusal happens here and nowhere earlier. Either decision removes the tag.

The reading question is the human's tie-breaker: of the lines that passed the chain test, promote the ones answering why the book was opened. Draft each promoted page to its type's required slots, quote the source verbatim, and count what you checked. The human judges twice — the candidate line first, then the draft. One home per fact; a fact that already has a page updates that page.

Read [COMPILE](references/COMPILE.md); page shapes in [TYPES](references/TYPES.md); quotes and warrants in [EVIDENCE](references/EVIDENCE.md).

Completion: no candidate in this source is ambiguous — each line reads promoted, refused, or still tagged; every promoted page fills its type's required slots; the book hub names the pages this source produced.

## 05 QUERY — answer from the wiki

Start at `index.md`, then match frontmatter and read only the pages that match. Answer from the wiki and cite the pages you used. When the wiki is silent or suspected wrong, open that one source as a declared exception and close the gap in the same run. A reusable answer is filed as a page, not left in chat.

Read [QUERY-LINT](references/QUERY-LINT.md).

Completion: the answer cites the wiki pages it draws on, and any reusable synthesis is filed as a page.

## 06 LINT — keep it honest

Structure first, then meaning: links, quoted spans, slots and types, then contradictions, staleness, orphans, candidates that have sat tagged across several sweeps, ideas that keep appearing without a page of their own.

Read [QUERY-LINT](references/QUERY-LINT.md).

Completion: every issue reported as `page → problem → fix` with the structural fixes applied in the run, then 2–5 questions worth investigating and 2–5 sources worth fetching.

## Beyond the cycle

- **Add or reshape a type** — propose, never assume; the registry lives in the vault's `AGENTS.md`. [TYPES](references/TYPES.md).
- **A new vault** — scaffold the folders, seed the registry, then build the views. [LAYOUT](references/LAYOUT.md).

## References

`references/` — [READ](references/READ.md) · [EXPLORE](references/EXPLORE.md) · [CURATE](references/CURATE.md) · [COMPILE](references/COMPILE.md) · [QUERY-LINT](references/QUERY-LINT.md) · [TYPES](references/TYPES.md) · [EVIDENCE](references/EVIDENCE.md) · [LAYOUT](references/LAYOUT.md). Each stage above points at the file it needs; [VOCABULARY](references/VOCABULARY.md) is the vocabulary.
