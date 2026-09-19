---
name: llm-wiki
description: Keep the Obsidian vault as a persistent LLM wiki — read a source into a source record, promote what matters into knowledge pages, answer questions from the wiki, lint it, and add a page type when new material needs one. Use when ingesting a book chapter, paper, or article into the vault, promoting material into knowledge, asking what the wiki says, health-checking the wiki, or reshaping a page type.
---

# LLM Wiki

The vault is the wiki. A source is read once and compiled into pages that stay current; later questions are answered from the wiki, not from the source.

You write and maintain every page. The human curates sources, reads them, and decides what matters. That division is the design: the bookkeeping is what no human sustains.

Reading belongs to the human — pace, dialogue, how much gets read before a session are theirs to set. This skill starts once a chapter has been read, or is being read together.

## The loop

Ingest → promote → query → lint. Types change rarely, and only by agreement.

Four words carry through all of it:

- **Source record** — the page saying what a text says and where. Evidence: it holds no claims.
- **Promotion** — moving material from a source record into a knowledge page. The only way a knowledge page is born, and always a human decision.
- **Registry** — the vault's list of accepted page types, kept in the vault's `AGENTS.md`.
- **One home** — each fact lives on exactly one page; other pages link to it.

## 1. Orient

Read the vault's `AGENTS.md` (its registry and conventions), then `index.md`. The vault is the directory holding `.obsidian/` — `~/Projects/Obsidian-Vault` unless the human says otherwise. Read [LAYOUT](references/LAYOUT.md) when the vault is new, or when folders, frontmatter or views are in question.

Completion: the registry is in context and you know which types this vault accepts.

## 2. Ingest a source

One chapter or article per run. Read [INGEST](references/INGEST.md) before fetching anything; every verbatim quote follows [EVIDENCE](references/EVIDENCE.md).

Close by putting a **candidate list** to the human: 2–5 items, each naming the page it would create or update, the type it would take, and one line of why.

Completion: the source record exists with its `§` map, its anchors and its `quotes_check:` count; the human has answered the candidate list — struck items, added items, or approved as it stands.

## 3. Promote

Read [TYPES](references/TYPES.md). Write or update one knowledge page per approved candidate, then link the source record where the link carries meaning.

Completion: every approved candidate is a page or a section inside one; every page names a type from the registry and fills that type's required slots; each promoted fact has one home.

## 4. Query

Start at `index.md`, then match frontmatter and read only the pages that match: `[type:argument]`, `tag:#naming`, `[sources:多元论]`, `section:(naming exception)`. Cite the pages you used. When the wiki is silent or suspected wrong, open that one source as a declared exception and close the gap in the same run.

Completion: the answer cites the wiki pages it draws on; a reusable synthesis is filed as a page rather than left in chat.

## 5. Lint

Read [TYPES](references/TYPES.md) and [EVIDENCE](references/EVIDENCE.md). Structure first — required slots present, `quotes_check:` matching the page's `>` blocks, links resolving, every page typed from the registry — then semantics: contradictions, stale claims, orphans, ideas that keep appearing without a page of their own.

Completion: every issue reported as `page → problem → fix` with structural fixes applied in the run; then 2–5 questions worth investigating and 2–5 sources worth fetching.

## 6. Add or reshape a type

Propose, never assume — one message carrying the name, the question it answers, its failure test and its required slots. The human accepts; the entry goes into the vault's `AGENTS.md`. Default shapes live in [TYPES](references/TYPES.md); the vault's `templates/` holds the human's overrides.

Completion: the registry entry is written into the vault's `AGENTS.md`, and the shape exists in `templates/<type>.md` when the human wants one.

## References

- [INGEST](references/INGEST.md) — finding a source, fetching a chapter, the source record's shape, the candidate list.
- [TYPES](references/TYPES.md) — the registry, its seed entries, the admission rule, the default shape of each type.
- [EVIDENCE](references/EVIDENCE.md) — the quote protocol, honesty tags, anchors.
- [LAYOUT](references/LAYOUT.md) — folder roles, frontmatter, views, publishing, wording.
