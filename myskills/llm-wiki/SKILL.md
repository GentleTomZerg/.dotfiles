---
name: llm-wiki
description: Keep the Obsidian vault as a persistent LLM wiki — read a source into a source record, stage candidates as you read, sweep them into knowledge pages, answer questions from the wiki, lint it, and add a page type when new material needs one. Use when ingesting a book chapter, paper, or article into the vault, sweeping staged candidates, promoting material into knowledge, asking what the wiki says, health-checking the wiki, or reshaping a page type.
---

# LLM Wiki

The vault is the wiki. A source is read once and compiled into pages that stay current; later questions are answered from the wiki, not from the source.

You write and maintain every page. The human curates sources, reads them, and decides what matters. That division is the design: the bookkeeping is what no human sustains.

Reading belongs to the human — pace, dialogue, how much gets read before a session are theirs to set. This skill starts once a chapter has been read, or is being read together. Deciding belongs to the human too, and it happens in a separate run, because reading wants recall and deciding wants precision.

## The loop

Ingest → sweep → query → lint. Types change rarely, and only by agreement.

Five words carry through all of it; [CONTEXT](CONTEXT.md) holds the whole vocabulary.

- **Source record** — the page saying what a text says and where. It holds no claims; it also holds the reading: the `§` map, the chain, the candidates, the refusals.
- **Candidate** — a line in a source record's `Candidates` slot, tagged `#candidate/<proposed type>`. Read, proposed for a page, undecided. The tag means undecided and nothing else.
- **Promotion** — moving a candidate into a knowledge page. The only way a knowledge page is born, and always a human decision.
- **Registry** — the vault's list of accepted page types, kept in the vault's `AGENTS.md`.
- **One home** — each fact lives on exactly one page; other pages link to it.

## 1. Orient

Read the vault's `AGENTS.md` (its registry and conventions), then `index.md`. The vault is the directory holding `.obsidian/` — `~/Projects/Obsidian-Vault` unless the human says otherwise. Read [LAYOUT](references/LAYOUT.md) when the vault is new, or when folders, frontmatter or views are in question.

Completion: the registry is in context and you know which types this vault accepts.

## 2. Ingest a source

One chapter or article per run. Read [INGEST](references/INGEST.md) before fetching anything; every verbatim quote follows [EVIDENCE](references/EVIDENCE.md).

Ingest is the generous half. Write the `§` map, the chain, and every item the chain test admits as a tagged candidate line — and take no decision about any of them. Two to five candidates is a good sign, not a rule; none is a legitimate answer, written as the slot's one line with its reason.

Completion: the source record exists with its `§` map, its anchors, its `quotes_check:` count, its `Candidates` slot holding either tags or a reason, and every tagged line carrying a role.

## 3. Sweep

Read [TYPES](references/TYPES.md). Sweep one source at a time, with the human: every tagged line becomes a promotion (`→ [[page]]`), a refusal (the rewritten line with its one-line reason), or stays tagged and open. The tag goes on either decision, and the human takes every one of them.

Completion: no candidate is left in an ambiguous state — each line reads as promoted, refused, or tagged; every promoted page fills its type's required slots; the book hub's inventory names the pages this sweep produced.

## 4. Query

Start at `index.md`, then match frontmatter and read only the pages that match: `[type:argument]`, `tag:#naming`, `[sources:多元论]`, `section:(naming exception)`. Cite the pages you used. When the wiki is silent or suspected wrong, open that one source as a declared exception and close the gap in the same run.

Completion: the answer cites the wiki pages it draws on; a reusable synthesis is filed as a page rather than left in chat.

## 5. Lint

Read [TYPES](references/TYPES.md) and [EVIDENCE](references/EVIDENCE.md). Structure first — required slots present, `quotes_check:` matching the page's `>` blocks, links resolving, every page typed from the registry, every candidate carrying a role, every refusal carrying a reason — then semantics: contradictions, stale claims, orphans, candidates that have sat tagged across several sweeps, ideas that keep appearing without a page of their own.

Completion: every issue reported as `page → problem → fix` with structural fixes applied in the run; then 2–5 questions worth investigating and 2–5 sources worth fetching.

## 6. Add or reshape a type

Propose, never assume — one message carrying the name, the question it answers, its failure test and its required slots. The human accepts; the entry goes into the vault's `AGENTS.md`. Default shapes live in [TYPES](references/TYPES.md); the vault's `templates/` holds the human's overrides. Role vocabulary is a separate matter and is reshaped the same way, into the vault's `AGENTS.md`.

Completion: the registry entry is written into the vault's `AGENTS.md`, and the shape exists in `templates/<type>.md` when the human wants one.

## References

- [INGEST](references/INGEST.md) — finding a source, fetching a chapter, the source record's shape, writing the candidates.
- [TYPES](references/TYPES.md) — the registry, its seed entries, the admission rule, the default shape of each type, the bar and the sweep.
- [EVIDENCE](references/EVIDENCE.md) — the quote protocol, honesty tags, anchors.
- [LAYOUT](references/LAYOUT.md) — folder roles, frontmatter, views, publishing, wording.
