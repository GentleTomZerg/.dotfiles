# Migrate — moving a book (or one page) to a new shape

Shape changes are the highest-risk edit in this wiki, because every page citing a source page by `#§n` breaks silently when a heading is renamed. Run this procedure instead of rewriting by hand.

1. **Inventory the anchors that must survive.**

   ```sh
   cd reading/<book>
   grep -rho "<chapter>#[^]|]*" wiki/ index.md --include="*.md" | sort -u
   ```

   Freeze that list. Those `### §n <section title>` headings must appear **byte-identical** in the new page. If one must change, that is a separate decision: update every citation in the same commit and say so in the log entry.

2. **Decide the target shape.** Write the new cores into the conventions block in `AGENTS.md` first, so the page is written against the new contract rather than the old one. Material no core claims moves into the spine's § record, moves to `wiki/concepts/` or `wiki/persons/`, or is dropped — dropping is legitimate, and the log should say so. **Deleting a spine block is a shape change like any other**: dropping `## Quote check` for the no-table mode means every `[verbatim]` ground must be re-checked against raw *before* the table goes, and the log entry must say that verification moved out of the page and where it went. State the cost to the human first — the switch is not reversible by looking at the page.

3. **Rewrite, preserving the anchor contract** — headings identical even while everything under them changes. Re-verify quotes: an older page's quotes were never checked against the [quote protocol](SPINE.md), so expect splice, framing, and transcription defects.

4. **Check the whole book, not just the page.** Every frozen anchor resolves in the new page; `concepts/`, `persons/`, `index.md`, `00-overview.md` still say what the page now says (a shape change often reveals that a concept page's gloss came from a paragraph that no longer exists); backlinks to the deleted file are gone.

5. **Close the loop.** Fold or delete the superseded draft — two files describing one chapter is the confusion migrations are meant to end. Update the conventions block, append a `migrate` entry to `log.md` naming the old and new shape and the anchor count, and run the structural lint pass from the skill's step 4.

## Notes

- Migrate one chapter per run, same as ingest. A book-wide migration is a sequence of chapter migrations plus one conventions-block change.
- Start with the most-cited source page, not the first one: that is where the anchor contract is actually load-bearing.
- One shape change, one log entry. The conventions-block edit that *declares* the new shape is part of the migration (step 2) and belongs in the same entry; an unrelated conventions change is a separate run — never folded in.
