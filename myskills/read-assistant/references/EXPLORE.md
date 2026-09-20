# Explore — one doubt at a time

EXPLORE is the agent's stage, run with the human in dialogue. Its input is a record whose `Questions` slot has `open` rows; its output is the same slot with no `open` row left. Nothing else in the vault changes, except a `live` doubt's copy into `index.md`.

## Work the list, one row at a time

The issue list is this record's `open` rows in file order, unless the human picks another. Take one, work it to a close with the human, write the close, then take the next. `open → investigating → closed` is the session's movement: `investigating` is what *you* are doing, and it is never written to the record. A run that dies mid-doubt leaves the row `open`, which is the truth.

One at a time is the point. A doubt closed while the next is already open gets a resolution the human has stopped attending to. The dialogue is where the human tests the answer; the agent's job there is to make it precise.

The agent's verbs here are retrieve, explain, compare, challenge, connect. Judge, choose and promote are not among them — the close written is the one the human accepts, not the one the agent prefers.

## Write per close

Write the closure into the row as soon as the doubt closes, before starting the next. Five closures written at the end of a run are five remembered answers: the defect this stage exists to prevent.

```md
- [ ] Q1 open — "为什么 §3 把多元论与相对主义并列？" — §3
- [x] Q1 answered — "为什么 §3 把多元论与相对主义并列？" — §3 → 相对主义只是多元论的一种退化读法 [stated]
- [x] Q2 dropped — "赫尔岑为何只在 §7 出场？" — §7 → 正文未给依据，不值得追
- [x] Q3 live — "多元论能否给出排序？" — §8 → 已抄入 index.md 我在追的（#live/多元论）
```

- **answered** — a one-line resolution, carrying exactly one warrant: `[stated]` (the text says it), `[reconstruction]` (the text implies it), `[mine]` (the human's, beyond any source).
- **dropped** — the reason it is not worth pursuing. A dropped doubt is a decision, not a failure: the reason is what stops the same doubt coming back at the next reading.
- **live** — the doubt outlives this source. Copy it, with its `Q` id, into `index.md` 我在追的, and tag the row `#live/<topic>` so the copy can be found.
- **open** — untouched. A row with no close and no reason stays as it was.

`[mine]` means the resolution is the human's position, beyond any source. When a close earns it, say so and let COMPILE route it to a `take` page; never relabel it `[stated]` to make it look settled.

## What may change in this run

- the row being closed, and no other;
- `index.md`, only for a `live` close;
- nothing else. Not the `§ map`, not the `Chain`, not the `Candidates` slot, and no knowledge page. If the exploration turns up material worth a page, that is a doubt to close, not a page to write.

A close that contradicts the record's `Chain` is a finding, not an edit: tell the human, and let the record be amended deliberately, in its own edit.

## What makes a close honest

- The resolution is one line. If it needs a paragraph, it is a page not yet written — say that, and close the doubt as `live` if it outlives the source.
- Every resolution names where it came from: a `§` anchor, a wiki page, or the human. An answer from nowhere is a memory, not an exploration.
- A passage is checked before it is quoted: follow the quote protocol in [EVIDENCE](EVIDENCE.md). Paraphrase is plain prose; a `>` block that was not checked does not belong in the record either.
- A doubt the human abandons mid-conversation is `dropped` with the reason, not left `open` and not closed on their behalf.

Completion: no `open` row remains in this record; every closed row carries its verdict word and its resolution, with a warrant where it has one; every `live` row appears in `index.md`.
