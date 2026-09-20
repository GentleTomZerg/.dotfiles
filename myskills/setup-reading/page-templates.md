# Page templates

Skeletons for `/skill:setup-reading` to seed the vault with, and for `/skill:ingest` to copy when it creates a page. The five **page types** go to `<vault>/templates/`, one file each, named for the type; `index.md`, `log.md`, `intent.md` and `inbox.md` go to the vault root. Trim sections that carry nothing — an empty heading is noise.

## Summary page — `wiki/summaries/<source-slug>/<unit>.md`

```markdown
---
type: summary
source: <title, author, year>
unit: <chapter or section>
locator: <page range, section number>
pass1: read <date>
---

# <Source> — <unit>

## What it says

<Compression in the source's own terms. No evaluation, no synthesis across sources.>

## Its argument

<Only when the unit argues: premises, the load-bearing premise, the conclusion, what it
is a response to. When the unit is autobiographical or historical instead, the causal
path goes here — how the positions formed, from what encounters and rejections. Delete
when the unit carries neither.>

## Noticed

<What the human flagged while reading, quoted or paraphrased as theirs.>

## Open questions

- <what this unit leaves dangling — and what would answer it>
```

## Concept page — `wiki/concepts/<idea>.md`

```markdown
---
type: concept
sources: ["[[<source-unit>]]"]
tested:
confidence:
---

# <Idea>

## In my words

<The human's formulation. Absent until a test passes solid; until then write
`> pending — no solid test yet` so the absence is visible.>

## Where it came from

<The problem this was invented to answer, and what it was a response to — the
answerable form of "how was this idea generated". Fill it from the source; hand it to
`/skill:research` when the origins lie outside the vault.>

## What the sources say

- **<Source, locator>** — <claim, attributed>

## Where they collide

<Two claims that cannot both stand, kept side by side with both attributions and the
reason the collision exists — different goals, different layer, or real disagreement.>

## Tests

<See the schema's test block.>
```

## Entity page — `wiki/entities/<name>.md`

```markdown
---
type: entity
sources: []
---

# <Name>

<What it is, in two or three sentences, and why it is in this vault.>

## Where it appears

- [[<page>]] — <role it plays there>
```

## Comparison page — `wiki/comparisons/<topic>-<a>-vs-<b>.md`

```markdown
---
type: comparison
sources: ["[[<a-unit>]]", "[[<b-unit>]]"]
---

# <Topic>: <A> vs <B>

## Positions

- **<A>** — <its position, its own terms>
- **<B>** — <its position, its own terms>

## The arguments behind them

<What each position rests on. Not what they claim — why.>

## Where they actually collide

<The cases where the two give different answers. Separate real disagreement from
verbal disagreement (same behaviour, different words) and from cases that differ only
because the two are answering different questions.>

## Cases each handles better

- <case> → <which source's rule applies, and why>

## Open questions

- <what evidence would settle this>
```

## Synthesis page — `wiki/syntheses/<topic>.md`

```markdown
---
type: synthesis
sources: ["[[<comparison-page>]]"]
status: open
---

# <Topic> — my position

## In my words

<The human's rule, in their phrasing. Promoted by a solid adjudication test.>

## The rule

<The decision rule, and the cases it covers.>

## Where it breaks

<The case the rule gets wrong. A rule with no breaking case has not been tested.>

## What would change my mind

<Required when `status: open`. A named unresolved position is a result; an invented
resolution is not.>
```

## `index.md`

```markdown
# Index

## Summaries
## Concepts
## Entities
## Comparisons
## Syntheses
```

## `log.md`

```markdown
# Log
```

## `intent.md`

```markdown
# Intent

## What I'll do with this

<The concrete thing — build it, decide it, argue it. Not "understand X".>

## What I don't care about

<The filter. This is what keeps ingest from filing what you will never use.>

## Changed

- <date> — <what changed and why>
```

## `inbox.md`

```markdown
# Inbox

Questions captured away from an agent. `/skill:lint-wiki` sweeps these onto the right pages.

- <question — where it came from>
```
