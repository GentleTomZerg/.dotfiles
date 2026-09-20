# Query and lint

The two runs that keep the wiki useful after the reading is over.

## Query

Start at `index.md`, then match frontmatter and read only the pages that match: `[type:argument]`, `tag:#naming`, `[sources:多元论]`, `section:(naming exception)`. The wiki is the first source of truth for anything it has already answered; the book is the exception, not the default.

- **Answer from pages, cite pages.** Every claim in the answer names the page it came from. An answer that cannot cite a page is either not in the wiki yet or was never explored.
- **The single-source exception.** When the wiki is silent on the question, or suspected wrong, open that one source — declared, not silent. Read it, answer, and close the gap in the same run: the answer becomes a page, or a `Questions` row when it turns out to be a doubt rather than an answer. An exception that leaves the gap open has spent the source and changed nothing.
- **File what is reusable.** An answer worth asking again is a page, not a chat message. A page drawing on several sources is a `synthesis` ([TYPES](TYPES.md)).

Completion: the answer cites the wiki pages it draws on; any reusable synthesis is filed as a page; a source opened under the exception left the gap closed.

## Lint

Structure first, then meaning. The order is not cosmetic: a broken link or a missing slot makes the semantic checks unreliable, and a structural fix is cheap while the page is open anyway.

**Structure** — every issue here is fixed in the run:

- required slots present for the page's type;
- `quotes_check:` matching the page's `>` blocks;
- links resolving — anchors frozen, wikilinks pointing at pages that exist;
- every page typed from the registry in the vault's `AGENTS.md`;
- every candidate carrying a role, and every refusal carrying a reason;
- no decided line still carrying `#candidate/…`;
- no `open` row left in a source whose EXPLORE run is done.

**Semantics** — reported, and fixed when the fix is not itself a judgement:

- contradictions between pages, and between a page and its source;
- stale claims a later source has overtaken;
- orphans, and pages nothing links to;
- candidates that have sat tagged across several sweeps — promote, refuse, or say why not;
- ideas that keep appearing in the reading without a page of their own;
- `[mine]` material sitting on a page with no `take`.

Report every issue as `page → problem → fix`, and apply the structural fixes in the run. Then close with 2–5 questions worth investigating and 2–5 sources worth fetching: lint is also where the next reading gets chosen.

Completion: every issue reported as `page → problem → fix`, with the structural fixes applied; 2–5 questions and 2–5 sources named.
