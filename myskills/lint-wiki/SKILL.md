---
name: lint-wiki
description: Health-check the vault — contradictions, red links, orphans, stale claims, gaps — and surface what to read or settle next.
disable-model-invocation: true
---

# Lint the wiki

Run every few ingests, or when the vault has stopped feeling like something you could trust. The wiki degrades in ways its own pages cannot see: claims that later sources superseded, ideas named but never given a page, questions asked once and forgotten.

Locate the vault and read its schema.

## Checks

Work all of them. Each is a search you can run and a finding you can act on.

| Check | Look for | Then |
|---|---|---|
| **Contradictions** | pages holding claims that conflict, with no cross-flag | flag in place, both attributions, and open a comparison if it is real |
| **Stale claims** | a claim a later ingest superseded but no page says so | revise the claim, cite the newer source, note what changed |
| **Red links** | concepts named but lacking a page, repeatedly | create the page from the mentions, or fold the term into the page that owns it |
| **Orphans** | pages with no inbound links | link them from the page they belong to, or archive them |
| **Missing cross-references** | pages that share an idea and don't link | link both ways |
| **Open questions** | every `## Open questions` bullet, plus `inbox.md` | answer the ones the vault can now answer (a `/skill:query` filing-back job); keep the rest, sharpened |
| **Gaps** | what a new source or a web search would fill | a candidate source list — this is the forward view |
| **Test coverage** | pages with no tests, and pages still `unlearned` | propose tests; `unlearned` pages go back to a re-read |
| **Intent drift** | pages that no longer serve the intent | propose archiving, never deletion |

## Steps

1. Run the checks and collect findings. **Completion:** every check has run, and each finding names the page and the fix.

2. **Fix what is unambiguous, in place** — red links, orphans, cross-references, stale claims the sources settle. These need no permission.

3. **Bring the judgement calls to the human, as a short list** — one line per finding, the fix you propose, nothing else. Contradictions that need a comparison, gaps that need a source, pages that should be archived, intent drift.

   **Completion:** every judgement call has been put to them, and they have answered or deferred.

4. **Apply the accepted fixes**, and record what was deferred as open questions rather than dropping it.

5. **Report the forward view**: the questions still open, the sources worth reading next, and the pages that a solid test session should visit. That list is the thing the human actually uses.

6. **Log it** — `## [<date>] lint | <n> findings, <n> fixed`.

## Judgement

- **Archiving is not deletion.** A page that no longer serves the intent is archived with its links intact; a page that is simply wrong is revised. `raw/` is never touched either way.
- **A lint pass that only tidies has failed.** The point is to notice what is *missing* — a contradiction nobody flagged, a concept the vault keeps using without defining, a question that has quietly become answerable.
- **Aggregate the open questions, don't centralise them.** They stay on the pages they hang off; the lint pass reads them all and reports. A separate tracker would go stale the moment someone edited a page.
