---
name: wiki-query
description: Ask the vault a question, get an answer with its citations, and file the good answers back as notes. Pass 3 of the reading loop.
disable-model-invocation: true
---

# Query

Pass 3: the human argues with you about what they read — their question arrives as the argument. Answer from the notes and the sources, and **file good answers back** — the whole point of pass 3 is that its product survives the conversation.

This is the vault's answering skill, and the question needs no reading behind it: *what does this author mean by X*, on a book the vault has never seen, is a legitimate entry, and *the vault cannot answer that yet* is a legitimate outcome. What it does not do is compress a source the human has not read (that is `/skill:ingest`) or hand them a position (that is `/skill:wiki-synthesize`).

Locate the vault and read its schema. The schema is authoritative for the notes, citations and the invariants.

## Steps

1. **Find.** Read `index.md` first — it is the catalog and it is cheap. Then the relevant notes, then the raw source when the question turns on wording. `obsidian search query="…"` or `grep` for anything the index doesn't surface. Load only what the question needs.

   **Completion:** you can name the notes and source passages you will answer from.

2. **Answer, with the three levels kept apart.** Say plainly which is which — this is the value of asking the wiki rather than the open web:
   - **what the vault holds** — cite the note;
   - **what a source says** — cite the source and its locator, and quote it when the wording matters;
   - **what you infer** — mark it as yours, and say what would confirm it.

   When the sources disagree, present the disagreement rather than resolving it silently. An answer that quietly picks a side is the fastest way to corrupt the wiki.

   **Completion:** the human has an answer with every claim attributed, and can see where the sources disagree.

3. **Propose the filing, wait for yes.** Karpathy's rule: *good answers can be filed back into the wiki as new pages* — a comparison, an analysis, a connection you discovered, and nothing should die in chat history. Propose one filing as a short list — one line each, no prose selling — and wait for accept or defer before writing anything. A filing without their yes is filing without curation.
   - An answer that stands on its own becomes a note, or a section on the note it belongs to.
   - An answer the human will need repeatedly becomes a test (hand off to `/skill:wiki-recall` to write it).
   - An answer that explains *why* an idea exists, and needed material outside the vault, is a `/skill:research` job — dispatch it on primary sources and file the result when it lands.
   - An answer that cannot be settled with what the vault holds becomes an `## Open questions` bullet on the right note, saying what would answer it.
   - A collision needing a decision becomes a `/skill:wiki-synthesize` proposal — propose it, wait for yes, never start it here.

   **Completion:** every proposal is accepted or deferred, every accepted filing is written — never only in the conversation.

4. **Log it** — `## [<date>] query | <the question>`.

## Judgement

- **The source wins.** A note is a compiled claim, and compiled claims go stale. When the note and the source disagree, check the source and fix the note — say so, don't quietly rewrite.
- **Answer the question asked.** A question about what an author means is not a question about whether they are right; give the former, then offer the latter.
- **Naming an idea the vault does not hold is how the vault grows.** Say it plainly and let it become a candidate note; a vault that can only answer what it already holds is a lookup table.
