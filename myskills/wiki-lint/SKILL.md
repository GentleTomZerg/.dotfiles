---
name: wiki-lint
description: Health-check the reading vault — contradictions with no cross-flag, claims a later source superseded, questions nobody has answered — and surface what to read or settle next.
---

# Lint

The vault degrades in ways its own notes cannot see: a claim a later source superseded, a question asked once and forgotten, a unit whose depth was wrong. This is the agent's own housekeeping — it reaches for it after a batch of ingests, or when the vault has stopped feeling like something the human could trust — so the human never has to call it.

Locate the vault and read its schema.

## Checks

Work all of them. Each is a search you can run and a finding you can act on.

| Check | Look for | Then |
|---|---|---|
| **Contradictions** | notes holding claims that conflict, with no cross-flag | flag in place, both attributions, and propose a position to the human if the disagreement is real |
| **Stale claims** | a claim a later ingest superseded but no note says so | revise the claim, cite the newer source, note what changed |
| **Open questions** | every `## Open questions` bullet, plus `inbox.md` | answer the ones the vault can now answer (a `/skill:wiki-query` filing-back job); keep the rest, sharpened |
| **Recall coverage** | notes with no tests, and notes still `unlearned` | hand them to `/skill:wiki-recall`: propose the tests, and send `unlearned` notes back to a re-read |
| **Map drift** | a unit whose depth the reader's experience contradicts, or a book whose map was never reviewed | re-open the row against the reader's intent and the standing evidence |
| **Gaps** | what a new source would fill | a candidate source list — this is the forward view |
| **Intent drift** | notes that no longer serve the intent | propose archiving, never deletion |

## Steps

1. Run the checks and collect findings. **Completion:** every check has run, and each finding names the note and the fix.

2. **Fix what is unambiguous, in place** — stale claims the sources settle, a note the collision belongs on. These need no permission.

3. **Bring the judgement calls to the human, as a short list** — one line per finding, the fix you propose, nothing else. Contradictions worth a position, gaps that need a source, notes that should be archived, intent drift.

   **Completion:** every judgement call has been put to them, and they have answered or deferred.

4. **Apply the accepted fixes**, and record what was deferred as open questions rather than dropping it.

5. **Report the forward view**: the questions still open, the sources worth reading next, and the notes a recall session should visit. That list is the thing the human actually uses.

6. **Log it** — `## [<date>] lint | <n> findings, <n> fixed`.

## Judgement

- **Archiving is not deletion.** A note that no longer serves the intent is archived with its links intact; a note that is simply wrong is revised. `raw/` is never touched either way.
- **A lint pass that only tidies has failed.** The point is to notice what is *missing* — a contradiction nobody flagged, an idea the notes keep using without defining, a question that has quietly become answerable.
- **Aggregate the open questions, don't centralise them.** They stay on the notes they hang off; the lint pass reads them all and reports. A separate tracker would go stale the moment someone edited a note.
