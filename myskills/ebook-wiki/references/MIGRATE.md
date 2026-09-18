# Migrate — moving a book (or one page) to a new shape

Shape changes are the highest-risk edit in this wiki, because every page that cites a source page by `#§n` anchor breaks silently when a heading is renamed. Run this procedure instead of rewriting by hand.

## 1. Inventory the anchors that must survive

```sh
cd reading/<book>
grep -rho "<chapter>#[^]|]*" wiki/ index.md --include="*.md" | sort -u
```

Freeze that list. Those `### §n <节名>` headings must appear **byte-identical** in the new page. If a heading must change, the change is a separate decision: update every citation in the same commit and say so in the log entry.

## 2. Decide the target shape

- Which cores does the book declare now? Write them into `## 读法` in `AGENTS.md` first, so the new page is written against the new contract rather than the old one.
- What happens to material no core claims? It either moves into the spine's § record, moves to `wiki/concepts/` / `wiki/persons/`, or is dropped. Dropping is a legitimate outcome — say so in the log.

## 3. Rewrite, preserving the anchor contract

Keep `### §n <节名>` identical even while everything under them changes. Re-verify quotes: an older page's quotes were never checked against the [quote protocol](../SPINE.md), so expect splice, framing, and transcription defects. Record results in `## 引文核对`.

## 4. Check the whole book, not just the page

- every frozen anchor resolves in the new page;
- `concepts/`, `persons/`, `index.md`, `00-overview.md` still say what the page now says (a shape change often reveals that a concept page's gloss came from a paragraph that no longer exists);
- backlinks to the old, now-deleted file (a `-v2` draft, a renamed chapter) are gone.

## 5. Close the loop

- Delete or fold the superseded draft — two files describing one chapter is the confusion migrations are meant to end.
- Update `AGENTS.md` `## 读法` and its `本书约定`-style notes.
- Append `## [YYYY-MM-DD] migrate | <chapter> | <old shape> → <new shape>, N anchors verified` to `log.md`.
- Run the structural lint pass from the skill's step 4.

## Notes

- Migrate one chapter per run, same as ingest. A book-wide migration is a sequence of chapter migrations plus one `## 读法` change.
- Do not migrate a page nobody cites first: start with the most-cited source page, since that is where the anchor contract is actually load-bearing.
- Never migrate and change conventions in the same step. One shape change, one log entry.
