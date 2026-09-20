# Types — the registry of page shapes

The registry is the closed half of the vocabulary, and it lives in the **vault's `AGENTS.md`, which is authoritative**. This file seeds it and holds the default shape of each type. Tags are the open half: unlimited topics, no admission.

An entry carries four parts and no more:

- **question** — what a page of this type answers that no other type answers.
- **failure test** — what makes a page of this type wrong. This is what lint applies.
- **required slots** — the sections a page must carry.
- **default shape** — the skeleton to write, overridable in the vault's `templates/`.

A type enters the registry when the human accepts it, and only when its failure test differs from every existing entry. Material that fits no entry is filed as the nearest type with the doubt written into a `take`: the writing keeps moving, and the gap stays visible.

## Seeded

### source — a record of what a text says
- **question**: what does this text say, and where?
- **failure test**: a quote is not verbatim; an anchor does not resolve; a candidate carries no role; a decision was written without removing the tag.
- **slots**: `Gist` (the chapter's main claim in one breath) · `Chain` (the load-bearing steps, each naming the page it yields) · `Candidates` (tagged proposals, then their outcomes) · `Open` (`[mine]` questions this reading produced) · `§ map` (one to three lines per section — the map, anchors frozen) · `Entries` (dates, names, metaphors; lookups) · `Glossary` (terms the chapter defines and no page holds).
- Holds no claims, no arguments, no `[mine]` outside `Open`. It speaks about the text, never about the world ([ADR 0003](../docs/adr/0003-source-records-speak-about-the-text.md)), which is what lets it be mutated on every sweep. A reading the chapter merely implies belongs on a promoted page.

### book — the hub for one source
- **question**: what is in this book, how far have I read, what did it produce, and what am I after?
- **failure test**: a chapter, or a page a chapter produced, is missing from the inventory; a `§` citation no longer resolves; the reading question is missing.
- **slots**: `Reading question` (why this book was opened — the bar's second half; `随手翻，没问题` is an honest answer) · progress · the chapter list with one-line gists · the chapter → produced-page inventory · this book's shape notes (which slots matter here, and any template overrides it wants).

### concept — a distinction
- **question**: what does this term mean here, and how does it differ from its neighbours?
- **failure test**: the contrast is wrong — one concept read as another.
- **slots**: the distinction in one line · the contrast (what it is *not*) · each source's usage · the human's position · evidence links.
- A concept page with one source and no disagreement says so outright. That is honest, and it is the floor of the shape.

## On demand — propose these, never assume them

### argument — a warranted inference
- **question**: does this conclusion hold?
- **failure test**: an inference step does not follow, a ground is misread, or the falsifier is already met.
- **slots**: **C** one falsifiable sentence · **G** numbered grounds, each tagged and located · **W** what licenses G → C · **I** the steps, written out and named · **S** which grounds carry the claim and which are inert · **R** the falsifier.
- **W** and **R** are the two slots that go missing; write them and tag them.
- Restraint is usually the finding: "monism has no warrant" is not the claim "monism is false", and the difference is the point.

### practice — what to do in a situation
- **question**: in this situation, what should be done?
- **failure test**: the situation does not hold, or the cost is unstated.
- **slots**: the prescription in one line · a per-source table `什么情况 / 要你做什么 / 为什么 / 代价 / 何时别用` · the mechanisms it leans on · the human's position · evidence.
- A prescription is fit-apt rather than truth-apt: it is not refuted by being untrue, but by its situation failing to hold.

### mechanism — how something works
- **question**: how does it work, and when does it break?
- **failure test**: the model cannot predict the behaviour, or the failure conditions are unstated.
- **slots**: what it solves · the mechanism · a diagram or code where it earns its place · how it fails · the trade-offs table `场景 / 好处 / 代价 / 何时别用`.

### trace — who did what, in what order, and why it mattered
- **question**: how did this come to be?
- **failure test**: a date is wrong, causation is reversed, or the telling is anachronistic.
- **slots**: timeline · positions table where several people differ · the causal chain · links out.

### take — the human's own position
- **question**: what does the human make of this?
- **failure test**: not truth-apt — a take is wrong when it is no longer what they think.
- **slots**: the position in their words · what it reacts to (links) · whether it is open or settled.
- A take may stay open forever, which is why it is not called a question.

## Promotion — the bar, the candidates, the sweep

Promotion is the only way a knowledge page is born, and it is always the human's decision. It happens in a sweep, never during the reading ([ADR 0002](../docs/adr/0002-candidates-are-staged-in-the-source-record.md)).

**The bar has two halves** ([ADR 0001](../docs/adr/0001-a-page-exists-for-the-chain-and-the-reading-question.md)):

- **The chain test** decides what may be proposed: remove the item from the chapter and its main claim breaks. It is the `Gist`, a `Chain` row, or a name the chain cannot be restated without. An item that merely illustrates a row is not a candidate; it stays in the `§ map` and `Entries`. The test is mechanical, so the agent applies it while reading.
- **The reading question** decides what is actually promoted. Of the items that pass the chain test, the human promotes the ones answering why the book was opened — the `Reading question` slot of its `book` hub. An item can pass the chain test and still answer nothing of the human's; it is then refused without shame, and the refusal keeps its reason.

**A candidate is a line** in the source record's `Candidates` slot: proposed type ｜ role ｜ item — why — `§`anchor `#candidate/<proposed type>`.

```md
- 概念｜核心主张｜多元论 — 全书骨，须与相对主义分开 — §8 #candidate/concept
- 人物｜例证｜赫尔岑 — §7 只出场一次，但「创造即一切」是他自己的一条线 — §7 #candidate/person
```

**The tag means undecided.** A sweep decides every tagged line:

- **promote** — write or update the page, then rewrite the line as `→ [[page]]` with the date. Every promoted page fills its type's required slots, and the book hub's inventory gains the page it produced.
- **refuse** — rewrite the line as `未提升：<reason>` with the date. The reason is what stops the same item being re-proposed at the next reading.
- **leave** — the tag stays. The item is genuinely undecided, and it is the only thing the candidate view shows.

Either decision removes the tag. Sweeping a source is the last thing that happens to it in a session; the reading was already done.

View the frontier with a Base: `file.hasTag("candidate")` over `sources/` lists the chapters still holding undecided candidates. Write the filter with `file.hasTag` and nothing else — it matches children (`#candidate/person`) and reads tags in the body, while `tags.contains` does neither.

**Roles** are required on every candidate and are free text for now: the accepted vocabulary lives in the vault's `AGENTS.md`, and the gate over it — whether a `背景` or `例证` may be promoted at all — is deliberately deferred. A role marks what the material does in its source; it does not decide.

Rules that keep the wiki honest as it grows:

- **Comparisons live in the table on the compared page.** Where sources differ, the per-source table is mandatory; prose about each source in turn is what a book report does, not a wiki.
- **Lineage with dates and authors goes to `trace`.** The practice or concept page keeps the current decision and links to the lineage.
- **A contradiction between sources is a row in the table, not a debate.** When it needs the human's judgement, it becomes a `take`.
- **A page that outgrows one question splits.** Announce the split, write both halves, then let the links resolve.
- **Per-book templates**: the book hub may name slot changes — a proof-heavy book leaning on `I` and `R`, say. The registry's required slots still apply.
