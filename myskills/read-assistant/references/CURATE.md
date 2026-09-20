# Curate — one answered row at a time

CURATE is a run of its own, and the human leads it. Its input is a record whose `Questions` slot has no `open` rows; its output is that record's `Candidates` slot — the export manifest — and nothing else. It never touches question status, never drafts a page, and never explains.

## Never touch the questions

The `Questions` slot was settled in EXPLORE. Curate reads it and leaves it exactly as found: every `answered` row keeps its status, its resolution and its warrant. A curate run that rewrites a resolution has re-opened a closed doubt in the wrong run.

## The chain test

Apply it to each `answered` row, in file order:

> Stage the row only if removing it breaks the chapter's main claim — it is the `Gist`, a `Chain` row, or a name the chain cannot be restated without.

An item that merely illustrates a row is not a candidate. It is residue, and the only question is whether it stays in the record or goes.

The test is mechanical, so the agent applies it. The verdict is the human's: the agent proposes, the human disposes, and when they disagree the human wins and the reason is written down.

The **reading question** does not act here. It is the human's tie-breaker at the sweep — of the rows that pass the chain test, COMPILE promotes the ones answering why the book was opened. Passing the chain test is permission to be staged, never a decision to be kept.

## The export manifest

One line per `answered` row, verdict first. The manifest is the record's `Candidates` slot.

```md
## Candidates

- staged｜Q1｜概念｜核心主张｜多元论不是相对主义的退化形式 — §8 → [[多元论]] #candidate/concept [stated]
- kept｜Q4｜赫尔岑只在 §7 举例，链条不经过他 — §7
- 无候选 — 本章只是复述，链条不经过任何可成页之物
```

**staged** — the row passes the chain test. The line carries, in order: the proposed type, the role, the claim in wiki words (a claim about the world, not a description of the source), the `§` anchor, the target page, and the warrant of the resolution it comes from. End it with `#candidate/<proposed type>`: the tag means undecided, and it is the only thing the candidate view finds.

**kept** — the row fails the chain test, or passes it without needing a page of its own. The item itself stays where the reading put it, in the `§ map` or `Entries`; the manifest keeps the one-line reason. Residue is not a refusal: nothing is being decided against, only left where it is.

**empty** — no row was staged. The slot opens with its one line and the reason: `- 无候选 — <why nothing in this chapter deserved a page>`. A chapter that yields nothing is a real answer, and it is never padded to look productive. Kept lines may still follow it: residue and yield are different questions.

One row, one line, one verdict. A row answered but absent from the manifest is a doubt that quietly died.

## No explaining

This run writes no case for anything. A staged line states the claim; the sweep will ask whether it holds. A kept line states the reason it stays. Prose defending either belongs in the EXPLORE dialogue, which is over, or in the page, which does not exist yet.

## Then stop

Write the manifest and stop. Tell the human which lines are `staged`; do not sweep them, and do not draft anything. The next run is COMPILE.

Completion: every `answered` row has exactly one manifest line; every `staged` line carries type, role, claim, anchor, target page, warrant and tag; every `kept` line carries its reason; the `无候选` line is present whenever nothing was staged.
