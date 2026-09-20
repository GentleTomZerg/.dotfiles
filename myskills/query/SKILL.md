---
name: query
description: Ask the wiki a question, get an answer with citations, and file the good answers back as pages. Pass 3 of the reading loop.
disable-model-invocation: true
---

# Query

Pass 3: the human argues with you about what they read — their question arrives as the argument. Answer from the wiki and the sources, and **file good answers back** — the whole point of pass 3 is that its product survives the conversation.

Locate the vault and read its schema. The schema is authoritative for page types, citations and the invariants.

## Steps

1. **Find.** Read `index.md` first — it is the catalog and it is cheap. Then the relevant pages, then the raw source when the question turns on wording. `obsidian search query="…"` or `grep` for anything the index doesn't surface. Load only what the question needs.

   **Completion:** you can name the pages and source passages you will answer from.

2. **Answer, with the three levels kept apart.** Say plainly which is which — this is the value of asking the wiki rather than the open web:
   - **what the wiki holds** — cite the page;
   - **what a source says** — cite the source and its locator, and quote it when the wording matters;
   - **what you infer** — mark it as yours, and say what would confirm it.

   When the sources disagree, present the disagreement rather than resolving it silently. An answer that quietly picks a side is the fastest way to corrupt the wiki.

   **Completion:** the human has an answer with every claim attributed, and can see where the sources disagree.

3. **File it back.** Karpathy's rule: *good answers can be filed back into the wiki as new pages* — a comparison, an analysis, a connection you discovered, and nothing should die in chat history.
   - An answer that stands on its own becomes a page, or a section on the page it belongs to.
   - An answer the human will need repeatedly becomes a test (hand off to `/skill:test-me` to write it).
   - An answer that explains *why* an idea exists, and needed material outside the vault, is a `/skill:research` job — dispatch it on primary sources and file the result when it lands.
   - An answer that cannot be settled with what the vault holds becomes an `## Open questions` bullet on the right page, saying what would answer it.

   **Completion:** the answer exists as a page, a section, a test, a research job, or a recorded open question — never only in the conversation.

4. **Log it** — `## [<date>] query | <the question>`.

## Judgement

- **The source wins.** A page is a compiled claim, and compiled claims go stale. When the page and the source disagree, check the source and fix the page — say so, don't quietly rewrite.
- **Answer the question asked.** A question about what an author means is not a question about whether they are right; give the former, then offer the latter.
- **Red links are an outcome, not an error.** Naming a concept the wiki lacks is how the wiki grows; leave the link and note the gap.
