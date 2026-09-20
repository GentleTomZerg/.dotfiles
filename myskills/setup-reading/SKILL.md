---
name: setup-reading
description: Scaffold the reading vault — layout, schema, page templates, intent, and the pointer in your global agent file. Run once before first use of the other reading skills.
disable-model-invocation: true
---

# Setup reading

Write the per-vault configuration the reading skills assume:

- **The vault** — where raw sources, the wiki, the index and the log live
- **The schema** — `AGENTS.md` at the vault root: page types, frontmatter, citation and linking conventions, the invariants
- **The intent** — what this reading is *for*, and what you don't care about
- **The pointer** — one line in your global agent file, so a session started outside the vault can still find it

This is a prompt-driven skill, not a script. Explore, present what you found, confirm with the human, then write.

## Steps

1. **Explore.** Read whatever exists; assume nothing.
   - **Candidate vaults** — the current directory; any directory with a `.obsidian/` marker; and `obsidian help`, which is authoritative for how the CLI names and targets vaults (commands take `vault=<name>` and target the most recently focused vault by default).
   - **Existing wiki furniture** — `index.md`, `log.md`, `wiki/` (or `summaries/` `concepts/` etc. directly), `raw/`, `intent.md`, `inbox.md`, and an `AGENTS.md` that already carries a schema.
   - **The global agent file** — `CLAUDE.md` or `AGENTS.md` in the home directory. Note which exists and whether it already has a reading pointer.
   - **Tooling actually present** — the `obsidian` CLI; a PDF text extractor (`pdftotext`); `pandoc`; an EPUB reader. These decide what the ingest step can promise.

   **Completion:** you can name every vault candidate, what each already contains, and which tools exist.

2. **Present findings, then ask one section at a time.** Lead with your recommendation so the human can accept it in a word. Skip any section exploration already settled.

   **A — Vault scope.** Reading-only vault, or a `reading/` subtree inside a vault that already has other content? A vault with non-reading content gets a subtree; a fresh one becomes the vault.

   **B — Where sources live.** `raw/` inside the vault (clipped articles, extracted chapters, pasted quotes) is the default. Offer `raw-link/` holding pointers to a large external library the vault must not copy.

   **C — Intent shape.** One `intent.md` at the vault root when the reading has a single purpose; `intent/<project>.md` when several reading projects share the vault. The template asks two questions and nothing more: *what will you do with this*, and *what don't you care about*.

   **Completion:** every section has an answer, each accepted in a word or edited.

3. **Show the drafts and let the human edit before anything is written:** the filled schema (`AGENTS.md`), the folder list, the intent file, and the exact line being added to the global agent file.

   **Completion:** the human has seen all four and approved or edited each.

4. **Write.**
   - Folders: `raw/`, `wiki/summaries/`, `wiki/entities/`, `wiki/concepts/`, `wiki/comparisons/`, `wiki/syntheses/`, and `templates/`.
   - `AGENTS.md` from [`schema-template.md`](./schema-template.md).
   - `templates/<type>.md` — one skeleton per page type, from [`page-templates.md`](./page-templates.md), so `/skill:ingest` has a skeleton to copy and Obsidian's template picker has them too.
   - `index.md`, `log.md`, the intent file, and `inbox.md` from the same skeletons.
   - In the global agent file, add a `### Reading vault` sub-block beside any existing skills block — never a second top-level section, and never overwrite the human's surrounding text.

   **Completion:** every listed file exists, and the pointer resolves to a real path.

5. **Done.** Tell the human the vault path, that the schema is now authoritative for every reading session, and that the loop starts with a unit they have read. Name the skills that will now read from it: `/skill:ingest`, `/skill:query`, `/skill:test-me`, `/skill:synthesize`, `/skill:lint-wiki`.

## Editing later

The schema is meant to be edited directly — it is the single source of truth for how this vault works, and the skills read it rather than restating it. Re-running this skill is only for moving the vault or starting the wiki over.
