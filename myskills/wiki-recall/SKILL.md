---
name: wiki-recall
description: Prove you know it — cold recall graded against the source. Solid passes promote your own words onto the note; what you keep failing gets pruned or sent back to a re-read.
disable-model-invocation: true
---

# Recall

The honest test: **can the human produce the idea from memory, in their own words?** Karpathy's warning is the reason this skill exists — *reading and understanding is not the same as replicating*, and it surprises people that they cannot write down what just made perfect sense.

This is the vault's review session, and the gate lives here: `ingest` admits candidate notes, and only this session turns one into the human's knowledge. It is also the only route by which their words enter the vault.

Locate the vault and read its schema. Tests live in the `## Tests` sections of the notes they test; the schema defines their shape and `must include` is already written on each one.

## Steps

1. **Collect what is due.** A test is due when it has no verdict, when its note is `shaky` or `unlearned`, or when its last verdict is older than the review interval (**default 14 days** — the human can change it). The human may name a note or topic to narrow the session; with no argument, take everything due.

   **Completion:** a listed set, with the note and form for each.

2. **Ask cold, one at a time.** State the prompt verbatim. No note open, no source, no paraphrase of the idea in the question, no hint — and **do not show `must include` until after they have answered.** It is a grading key, and showing it turns the test into a reading exercise. Wait for their words.

   **Completion:** they have given an answer, and you have not yet graded it.

3. **Grade against the source, not against the note.** The note is your own compression; grading against it lets the human pass by parroting the vault back. Check the source when the answer turns on a detail. Then:
   - name which `must include` elements are present and which are missing;
   - **quote the human's weakest sentence** — the specific line that is vague or wrong, in their words;
   - give one verdict: **solid**, **partial**, or **not-yet**.

   **Partial is not a pass.** A fluent answer that misses the load-bearing element is exactly the failure this skill is for. Never soften a verdict to be encouraging, and never upgrade one because the human pushed back — a challenged verdict is re-graded against the source or it stands.

   **Completion:** a verdict, quoting them, grounded in the source.

4. **Write the result.**
   - The verdict and date on the test; the note's `confidence` rolled up from its tests.
   - **On solid** — promote the human's sentence into `## In my words` on the note, marked as theirs. This is the only route by which their words enter the vault, and it is what makes the note their knowledge rather than a book report.
   - **On partial or not-yet** — their sentence is *not* promoted; it is the version being dislodged. Record the missing element in the test's `**待补**` line, with its locator, so the next attempt has something to aim at.
   - A gap the answer exposed that no note records becomes an `## Open questions` bullet on the note it belongs to.

   **Completion:** every test asked this session carries a new verdict, and every solid pass produced a promoted sentence.

5. **Count the failures.** A test failed twice is not evidence that the human needs quizzing harder — it is evidence that **pass 1 did not take**. Mark the note `unlearned`, stop testing it, and hand back the real fix: re-read the unit, then `/skill:ingest` it again. On the third pass escalate to a test that connects the idea to a neighbouring one, which is where a half-learned idea usually shows itself.

6. **Prune what they cannot say.** A note that has failed cold recall twice, and then failed again after the re-read, is not knowledge the human holds — it is a candidate the vault keeps on their behalf. Say so, and put the choice to them: archive the note, or keep it flagged `unlearned` as a reading note. Trim the failing part rather than the whole note when only part of it failed. The decision is theirs; the finding is yours.

   **Completion:** every note that failed this session has either a re-read handed back or a prune put to the human.

7. **Log it** — `## [<date>] recall | <note> — <n> solid, <n> partial`.

## Test forms

Pick the form that can actually fail for the thing the note holds.

| Form | Asks for | Fails when |
|---|---|---|
| **reproduce** | the idea, in the human's own words | the paraphrase is fluent and hollow — the load-bearing clause is missing |
| **reconstruct** | the argument: premises, the load-bearing one, the conclusion, what it answers | they can state the conclusion and not the ladder under it |
| **adjudicate** | a decision between conflicting sources, or a principle applied to a concrete case | they recite both positions and cannot choose, or their rule has no breaking case |

**Apply to their own work** is first-class for practice books — their real function, their real config, their real code — and it is the only form that separates *can explain deep modules* from *writes deep modules*. Reciting the principle earns nothing; the verdict turns on naming the specific change and its consequence.

## Judgement

- **One test at a time.** A batch invites skim-reading and short answers.
- **A test that cannot fail is not a test.** If every plausible answer would pass, rewrite the prompt or the `must include` before asking it.
- **Test what the intent needs.** A vault full of solid verdicts on things the human never wanted is a scoreboard, not knowledge.