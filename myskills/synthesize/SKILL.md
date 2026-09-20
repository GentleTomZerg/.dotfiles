---
name: synthesize
description: Turn several ingested sources on one topic into a comparison, then grill you into your own position on it.
disable-model-invocation: true
---

# Synthesize

Two books disagree, or three papers span one question — the topic arrives as the argument. This turns that pile into a **comparison** page and — with the human — a **synthesis**: their position, with the cases it covers and the case that breaks it. That position is the artifact no single source can give them, and it is why they read all of them.

Locate the vault and read its schema.

## Steps

1. **Gather.** Every page and summary touching the topic, and the passages behind each position in the raw sources. For each source get its **position in its own terms** and, more importantly, **the argument under it** — what it is optimizing for, which layer it is talking about, what it assumes.

   **Completion:** you can state each source's position and the reason it holds it.

2. **Separate the collisions from the noise.** Three things look like disagreement and only one is:
   - **Verbal** — same behaviour, different vocabulary. Merge into one page; note both names.
   - **Different questions** — the two are answering at different layers (a rule for writing a function vs a rule for designing an API). Not a conflict; record the boundary.
   - **Real disagreement** — the same case gets different answers. This is what the comparison page is for, and it is the only thing worth adjudicating.

   **Completion:** each apparent conflict is classified, with the classification justified from the sources.

3. **Draft the comparison page** — positions, the arguments behind them, where they actually collide, and which cases each handles better. **No verdict.** The comparison is analysis, and analysis is yours.

   **Completion:** the page is intelligible to someone who has read none of the sources, and contains no recommendation.

4. **Grill the human into their position.** Run `/skill:grilling` — rounds, the frontier, decisions are theirs — aimed at the rule they will actually hold: which cases they meet, what they will do by default, what they will give up, and where their rule breaks. You supply the cases and the consequences; they choose. Push on the breaking case until it is named: a rule that has never been cornered has not been decided, it has been repeated.

   **Completion:** they have stated a rule in their own words, and named a case it gets wrong.

5. **Write `wiki/syntheses/<topic>.md`** with `status: decided`, or `status: open`. **Open is a legitimate result** — a genuinely contested question gets `## What would change my mind` instead of a rule, and that is honest. Never invent a resolution to close a page; a named unresolved position is a finding, an invented one is a corruption.

6. **Generate the tests that can fail.** An adjudication test per collision (`must include` = the rule, its breaking case, and the distinction it rests on), and — when the sources are practice books — an **apply-to-their-own-work** test: bring one real case from their code or config and ask them to decide it. Hand off to `/skill:test-me` for the loop.

7. **Log it** — `## [<date>] synthesize | <topic> — <sources> → <decided|open>`.

## Judgement

- **Facts are yours, decisions are theirs.** You can establish that the two positions differ and what each costs. You cannot decide which one they hold — an agent-authored synthesis is a wiki of someone else's opinions.
- **A synthesis is not a summary of the majority.** It is a position, and it must say what it costs.
- **Re-open when a source lands.** A new ingest that contradicts a decided synthesis re-opens it: say so on the page, and put it in front of the human rather than quietly revising their position.
