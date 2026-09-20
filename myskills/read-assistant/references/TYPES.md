# Types — the registry of page shapes

The registry is the closed half of the vocabulary, and it lives in the **vault's `AGENTS.md`, which is authoritative**. This file seeds it and holds the default shape of each type. Tags are the open half: unlimited topics, no admission.

An entry carries four parts and no more:

- **question** — what a page of this type answers that no other type answers.
- **failure test** — what makes a page of this type wrong. This is what lint applies.
- **required slots** — the sections a page must carry.
- **default shape** — the skeleton to write, overridable in the vault's `templates/`.

A type enters the registry when the human accepts it, and only when its failure test differs from every existing entry. Material that fits no entry is filed as the nearest type with the doubt written into a `take`: the writing keeps moving, and the gap stays visible.

Propose a new type, never assume one. The proposal is one message carrying the name, the question it answers, its failure test and its required slots; the human accepts it, and the entry goes into the vault's `AGENTS.md`. The shape may then be written to `templates/<type>.md`.

## Seeded

### source — a record of what a text says
- **question**: what does this text say, and where?
- **failure test**: a quote in the record; an anchor that does not resolve; a candidate carrying no role; a decided line still tagged; an `open` row left behind after EXPLORE; a claim about the world.
- **slots**: `Gist` (the chapter's main claim in one breath) · `Chain` (the load-bearing steps, each naming the page it yields) · `Produced` (the Base listing the pages this chapter yielded) · `Candidates` (the export manifest, then the outcomes) · `Questions` (one row per doubt, with its status) · `§ map` (one to three lines per section — the map, anchors frozen) · `Entries` (dates, names, metaphors; lookups) · `Glossary` (terms the chapter defines and no page holds).
- It speaks about the text, never about the world, and holds no quotes (`quotes_check: 0`) — which is what lets it be mutated on every sweep without ever touching evidence. What the chapter merely implies belongs on a promoted page, tagged `[reconstruction]`.

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

### synthesis — one answer out of several sources
- **question**: what do these sources together say about this?
- **failure test**: the synthesis drops a source it draws on; it presents as a source's view what is the page's own step; its per-source table is missing.
- **slots**: the claim in one line · the per-source table — what each source contributes, and where they differ · the page's own step, tagged `[mine]` · what would overturn it · links to each source record.
- A synthesis is a page, not a stage: it is born by promotion like any other page, and its table is what keeps every contribution attributable. A synthesis existing only as a chat answer is a query that was not filed.

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
- A take may stay open forever, which is why it is not called a question. `[mine]` material from a resolution lands here.

## Rules that keep the wiki honest as it grows

- **Comparisons live in the table on the compared page.** Where sources differ, the per-source table is mandatory; prose about each source in turn is what a book report does, not a wiki.
- **Lineage with dates and authors goes to `trace`.** The practice or concept page keeps the current decision and links to the lineage.
- **A contradiction between sources is a row in the table, not a debate.** When it needs the human's judgement, it becomes a `take`.
- **A page that outgrows one question splits.** Announce the split, write both halves, then let the links resolve.
- **Per-book templates**: the book hub may name slot changes — a proof-heavy book leaning on `I` and `R`, say. The registry's required slots still apply, and none is dropped.

The bar that decides which material may be staged is the chain test ([CURATE](CURATE.md)); the decision that turns a staged line into a page is the sweep ([COMPILE](COMPILE.md)). This file holds only the shapes.
