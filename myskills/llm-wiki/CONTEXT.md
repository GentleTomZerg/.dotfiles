# LLM Wiki

The vault is the wiki: a source is read once and compiled into pages that stay current; later questions are answered from the wiki, not from the source. This is the language the `llm-wiki` skill and the vault's `AGENTS.md` share — the skill owns the mechanism, the vault owns the accepted word lists.

## Language

### The three kinds of material

**Source record**:
What a text says and where — one per chapter or article, at `sources/<book>/<chapter>.md`. It is the reading's record: the `§ map`, the chain, the candidates, the refusals. It speaks about the text, never about the world.
_Avoid_: reading note, summary, chapter page

**Candidate**:
A line in a source record's `Candidates` slot, tagged `#candidate/<proposed type>`: material read, proposed for a knowledge page, not yet decided. The tag means undecided and nothing else.
_Avoid_: todo, bookmark, idea

**Knowledge page**:
A page in `wiki/`, typed from the registry, answering that type's question. Born only by promotion.
_Avoid_: note, entry, card

### The bar

**Chain**:
The numbered rows of a chapter's main claim and the load-bearing steps to it (`M1…Mn` in the source record's `Chain`), each row naming the page it yields.
_Avoid_: outline, structure, spine

**Chain test**:
An item may be proposed as a candidate only if removing it breaks the chapter's main claim: it is the `Gist`, a `Chain` row, or a name the chain cannot be restated without. An item that merely illustrates a row is not a candidate — it stays in the `§ map` and `Entries`.
_Avoid_: centrality, importance, relevance

**Reading question**:
Why the source was opened — the `Reading question` slot of its `book` hub. The bar's second half: of the items that pass the chain test, the human promotes the ones that answer this.
_Avoid_: interest, theme, topic

**Live questions**:
Questions that outlive one source, listed in `index.md` under `我在追的`. A page answering one has global importance — which is why the same names recur across books.
_Avoid_: tags, topics, index

**Open question**:
A question a reading produced, living in that source record's `Open` slot as `[mine]`. Distinct from the reading question, which came before the reading, and from a live question, which outlives the source.
_Avoid_: question, unknown, gap

### The decision

**Promotion**:
Moving a candidate into a knowledge page — the only way a knowledge page is born, and always a human decision.
_Avoid_: publish, export, save

**Sweep**:
The run that decides staged candidates: promote, refuse with a reason, or leave. Always a separate run from the reading, so reading can be generous and deciding can be strict.
_Avoid_: triage, review, cleanup

**Refusal** (未提升):
A candidate decided against, kept as its rewritten line with a one-line reason and no tag. It stops the same item being re-proposed at the next reading.
_Avoid_: reject, discard, noise

**Role**:
What an item does in its source — core thesis, illustration, background, opponent, predecessor. Required on every candidate; the accepted vocabulary is the vault's, and the gate over it is deferred. A role marks; it does not decide.
_Avoid_: kind, category, type

**Empty yield**:
A source that produces no candidate, recorded as the `Candidates` slot's one line with its reason. Never padded to look productive.
_Avoid_: no_new_knowledge, zero yield

### Evidence

**Anchor**:
`### §n <title>` inside a source record — the only heading other pages link to. Frozen once written; numbers and titles quote the source.
_Avoid_: section, heading, block

**Quote protocol**:
A `>` block is verbatim only if checked against the source text in the same run that wrote it; paraphrase is plain prose. The count of checked spans goes into `quotes_check:`.
_Avoid_: citation, reference, excerpt

**Retrieval key**:
The first 8 characters of a quoted sentence, extended until unique in its chapter — how a human finds the passage in any reader on any machine.
_Avoid_: quote id, location, offset

**Honesty tag**:
`[stated]` (the source says it), `[reconstruction]` (the source implies it), `[mine]` (the human's, beyond any source). Every warrant carries exactly one.
_Avoid_: confidence, provenance, level

**One home**:
Each fact lives on exactly one page; other pages link to it. A second page needing the same quote cites it by anchor instead of copying it.
_Avoid_: single source of truth, dedupe

### The registry

**Registry**:
The vault's list of accepted page types, kept in the vault's `AGENTS.md`, which is authoritative.
_Avoid_: schema, vocabulary, config

**Type**:
A page shape entered by agreement, carrying a question no other type answers, a failure test, and required slots. The closed half of the vocabulary; tags are the open half.
_Avoid_: kind, class, category

**Failure test**:
What makes a page of a type wrong — what lint applies. Distinct from the chain test, which decides whether material deserves a page at all.
_Avoid_: validation, rule, check

**Required slots**:
The sections a page of a type must carry. The vault's `templates/` may override the skeleton, never drop a slot.
_Avoid_: fields, sections, format

## Retired

- **core / cores** — the deleted `ebook-wiki` notion of a book-level shape (`argue`, `record`, `trace`). Its job is done by the chain, the registry, and per-book shape notes. Still visible in the vault's older shape notes; do not reintroduce.
- **`no_new_knowledge:`** — replaced by the empty yield, a line in the `Candidates` slot, so the refusal to yield is visible where the reading happened.
- **`未成页` slot** — a proposed home for refused people and arguments; superseded by the `Candidates` slot, which records the refusal on the candidate line itself.
- **importance / centrality** — too vague to apply; replaced by the chain test and the reading question.
