# Compile — decide, then draft

COMPILE turns staged candidates into pages. It runs with the human, one source at a time, and it holds two judgements: the sweep over the candidate lines, then the reading of the draft.

## The sweep

Every tagged line in the source's `Candidates` slot gets exactly one of three outcomes, and the human takes each one:

- **promoted** — rewrite the line as `→ [[page]] (2026-09-20)`, and write or update the page in the same run.
- **refused** (未提升) — rewrite the line as `未提升：<one-line reason> (2026-09-20)`. The reason is what stops the same item being proposed again at the next reading.
- **left** — the tag stays, and the line is unchanged. The item is genuinely undecided.

Either decision removes the `#candidate/…` tag. The tag means undecided and nothing else, so a decided line still carrying one is a lie the candidate view keeps telling.

Refusal happens here and nowhere earlier. Curate staged, kept or yielded nothing; it never refused. A refusal first made at the sweep is the system working.

The **reading question** is the tie-breaker: of the lines that passed the chain test, promote the ones answering why the book was opened. A line can be load-bearing for the chapter and answer nothing of the human's — it is refused without shame, and the refusal keeps its reason.

## Draft the page

One promotion, one page, written in the same run. Read [TYPES](TYPES.md) for the type's required slots, and the vault's `templates/` for this vault's overrides.

- **Slots** — every required slot of the type, in the registry's order.
- **Claim** — the page's `gist:` is the claim in one breath. The body earns it.
- **Evidence** — a quote is verbatim only after a same-run check against the source, and the count goes into `quotes_check:`. Follow [EVIDENCE](EVIDENCE.md).
- **Warrants** — every inference step carries `[stated]`, `[reconstruction]` or `[mine]`; `[mine]` gets its `> [!warning] 我的发挥` and a `take` page to live on.
- **Links** — `sources:` in frontmatter names the records the page draws on; the body uses `[[wikilinks]]`.
- **One home** — a quote lives on the page where it does work; a second page cites it by anchor instead of copying it. A fact that already has a page updates that page — two pages holding the same fact is a merge, not a citation.

## The second judgement

The human judges twice: the candidate line at the sweep, then the draft. The first judgement is whether the item deserves a page; the second is whether the page says it right. Do not run them together — a draft shown before the line is decided is a page nobody asked for.

## After the sweep

- The book hub's inventory gains the pages this sweep produced ([TYPES](TYPES.md), `book`).
- The source's remaining lines are what the next sweep sees; a source whose lines are all decided drops out of the candidate view.
- Sweeping a source is the last thing that happens to it in a session. Its reading was already done.

Completion: no candidate in this source is ambiguous — every line reads promoted, refused, or still tagged; every promoted page fills its type's required slots; every quote was checked in the run that wrote it; the book hub names the pages this source produced.
