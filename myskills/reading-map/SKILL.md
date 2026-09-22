---
name: reading-map
description: Map a book before you read it — which units carry the ideas you came for, which to skim, what the volume cannot give you — then confirm the live row as you enter each unit. Book-open builds the map; unit-open confirms it.
disable-model-invocation: true
---

# Reading map

Two moments, one artifact. **Book-open** — before a book you have not read: where should your hours go, and what is this volume unable to give you? **Unit-open** — before each unit: what does this one owe you, and has the map's prediction held?

The map is **advice**, and advice is the product: what the book can and cannot give you, where not to go deep, and what the curve looks like. It is decided **once, before the read**, and it is the only place coverage is decided. A post-read list of everything the book contains is the failure this skill exists to prevent.

Pass 1 is still the reader's: the map allocates where their reading goes, never what it means.

Locate the vault and read its schema (`AGENTS.md`). The schema is authoritative for the intent rungs, what a note is, and how citations are written — this skill covers the map and nothing else.

## Book-open

1. **Take the volume's bearings.** The vault's purpose (its `intent.md`, or the project's file under `intent/`) says what this reading is for and what the reader does not care about. Then the book's own front matter and table of contents — preface, editor's note, edition notes. A volume's front matter is where its claims about itself live.

   **Completion:** you can say in three sentences what the volume offers and how it is built — how many units, which are essays, which are apparatus, what the edition added.

2. **Get the standing.** Dispatch `/skill:research` on the volume: for each unit, is it a **canonical** statement of something the reader came for, an **occasional** piece, or **apparatus**? Ask for the evidence and its locator behind each judgement, never a summary of the unit's argument.

   **Completion:** every unit carries a standing with evidence, or an honest "no source found" — a silent unit is a gap you are hiding.

3. **Draft the map**, in the shape below. Each unit gets exactly one **depth** — one of the levels the schema defines (`deep` / `light` / `skim`) — plus what to look for in it.

   **Completion:** a session could work from the draft without asking what any row means.

4. **Grill the reader** — `/skill/grilling`. What they came for, which units they care about against the vault's intent, how much time they have, and what they will give up. Push on the tempting unit that does not carry their question; push hardest on the units they will not finish.

   **Completion:** every row is accepted or changed by the reader, and the reader has said what this book is **not** for.

5. **Write the map** to the book's file under `intent/`. Then report what the map changes: which units earn the hours, which get skimmed, and where the reader's instinct and the evidence disagreed.

   **Completion:** the file exists, carries `provisional: true` and a `review:` line, and the reader has accepted it.

## Unit-open

1. **Read the row** for this unit, and re-read the neighbouring rows so the unit is placed rather than isolated.

2. **State the expectation** before the reading starts: the idea this unit should yield, its depth, and what to look for.

3. **Adjust the depth only when the map's prediction is visibly wrong** — a unit that turns out to be apparatus, or a light unit carrying the reader's question. Say what you changed and why.

4. **Do not write the `question` column.** That column is post-read: `ingest` writes it, along with `pass1` and the locator, when the unit is compressed. Guessing it here would put your words where the reader's belong.

## The map

```markdown
## What this book is for
## The ideas it should yield
## The units
## Beyond this volume
## What this book is not for
## Review point
```

`## The units` is the per-unit ledger, and its columns are what a later session works from:

| unit | standing | depth | what to look for | `pass1` | `question` | locator |

`standing` — canonical · occasional · apparatus. `depth` — one of the schema's levels. `pass1` and `question` stay empty until the unit is read: `ingest` fills them. `locator` is the scheme this book is cited by (the schema defines the grammar), so a citation can be resolved from the table alone.

## Judgement

- **Advice, not summary.** The map never compresses a unit's argument — that is the reader's read and then `ingest`. A map that gives away its units has spent the reading it was meant to spend well.
- **Standing is not worth.** An occasional piece can be the most enjoyable in the volume and a canonical statement can be dull. Standing answers *does this carry the ideas you came for*; depth follows the reader's question and their hours, not the canon.
- **Say no when no is the answer.** A sampler, a themed anthology, or a volume whose ideas live elsewhere gets that said on its cover — the map's job is to say it to the reader before they spend the hours. Answering "no, and here is where the ideas actually are" is a full result.
- **Two sources, one unit.** When a session spans two books or a book and an article, the map names the ambiguity rather than guessing, and says which volume the unit's depth belongs to.
- **Provisional until it is tested.** The map's deep calls are predictions. `review:` names the unit after which the reader should look again — if the load-bearing units did not carry what the map claimed, the rest of the map is worth re-reading before it is trusted.
