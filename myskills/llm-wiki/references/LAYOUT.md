# Layout — where things live

Folders carry **role**, never topic. Topics are `tags`; shapes are `type`; views are `.base`.

```
<vault>/
  index.md                        front door: hero block + 我在追的 + links to the views
  raw/<book>/book-info.md         source identity: file, sha256, chapter ids
  sources/<book>/<chapter>.md     the reading's record: map, chain, candidates, refusals
  wiki/*.md                       knowledge pages, flat, typed by frontmatter
  views/*.base                    one per type, plus the candidate view
  templates/*.md                  page shapes, human-owned, never published
```

`index.md` opens with a frozen block — `<!-- hero:start --> … <!-- hero:end -->` holding the avatar and intro. Write outside it, and treat everything inside as untouchable.

## Frontmatter is the index

| property | | example |
|---|---|---|
| `type` | closed vocabulary, from the registry | `concept` |
| `tags` | open topics; reuse before inventing | `[naming, software-design]` |
| `sources` | the source records the page draws on | `[sources/观念的力量/哲学的目的]` |
| `updated` | date of the last real change | `2026-09-19` |
| `quotes_check` | how many `>` spans were checked in the run that wrote them | `46` |
| `aliases` | the same idea in the other language | `[pluralism, value pluralism]` |
| `publish` | `true` for sources, books, knowledge; `false` for takes | `true` |

Set each property's type once in Obsidian (Settings → Properties) — text, list, date, number — so Bases can sort and count them. Pages are found by matching these values and reading only the matches: there is no catalog file, so nothing can go stale.

A candidate is not a property: the mark is a body tag, `#candidate/<proposed type>`, and the tag's meaning is *undecided*. The reading question is not a property either — it is a slot on the `book` hub, because the bar reads it as prose.

## Views

One `.base` per type, plus the candidate view — that one is a state, not a type: `file.hasTag("candidate")` over `sources/` is the sweep worklist, and a chapter leaves it once every line is decided. Build views in Obsidian's UI; for the syntax read the `obsidian-bases` skill. A view is a lens, never a source of truth — when a view and a page disagree, the page wins and the view gets rebuilt.

## Publishing

`publish: true` publishes. `templates/` and `private/` are already excluded by Quartz's `ignorePatterns`. Takes default to `publish: false` — half-formed thinking is worth keeping and not worth showing. Candidates are the exception: they live inside source records, so they publish with them, and a public `/tags/candidate` list is the frontier of the wiki shown in daylight. Bases render on the published site as static tables.

## Wording

The source's language governs the pages that report it, and each key term is glossed once on first use: `一元论 (monism)`. Keys stay English — frontmatter values, type names, tags, `§`. A page's name takes the language it was first promoted in, and carries the other language in `aliases`. Links use the shortest form — `[[多元论]]` — which survives any later move.

## New vault, first run

Scaffold the folders above, write `AGENTS.md` with the seed registry from [TYPES](TYPES.md), fence the hero block in `index.md`, write the `我在追的` section, then build the views — including the candidate worklist. Nothing here needs a stored path: links resolve by name, and the vault directory is the one holding `.obsidian/`.
