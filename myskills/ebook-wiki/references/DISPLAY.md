# Display — Obsidian constructs for reading notes

What you can *show* with, and which is right for which job. Verified against the official Obsidian docs (callouts, embeds, internal links, Obsidian Flavored Markdown). 已用 = already used in this vault; 建议 = supported but not yet used; 慎用 = works, costs something.

## Job → construct

| What you're showing | Use | Status |
|---|---|---|
| causal / dependency / derivation chain | mermaid `flowchart TD` with labeled edges (`A --converts--> B`) | 已用 |
| sequence in time | `timeline`; `sequenceDiagram` for actor-to-actor | 已用 |
| state transitions | `stateDiagram-v2` | 建议 |
| classification / grid | a table | 已用 |
| trade-offs | a table that **must** have a "when not to use" column | 建议 |
| verbatim quote | `>` block + a source line | 已用 |
| key quote, collapsed | `> [!quote]- Title` | 已用 |
| the agent's own step | `> [!warning] My own addition` | 已用 |
| the reader's own note | `> [!note] Reader's note`, kept out of quote blocks | 建议 |
| section inventory | `### §n Section name` | 已用 |
| math / logic | `$inline$`, `$$…$$` (including `\begin{align*}`) | 已用 |
| code | fenced with language + provenance (listing number or `file:line`) | 已用 |
| an image the human supplied | `![[img.png\|300]]` (width alone scales proportionally) | 已用 |
| **citing one sentence** | block id on the quote block, cited as `[[page#^block-id]]` | 建议 |
| **quoting without re-typing** | `![[page#^block-id]]` transclusion | 建议 |
| **one page of a PDF book** | `![[book.pdf#page=42]]` (add `#height=400` if needed) | 建议 |
| emphasising the operative phrase | `==…==` | 建议 |
| open questions / todos | `- [ ]`, collectable across chapters by a Base | 建议 |
| editorial notes and collation | footnotes `[^1]`, so the body stays readable | 建议 |
| concept aliases | frontmatter `aliases:`, so `[[一元论]]` and `[[monism]]` both resolve | 建议 |
| cross-chapter overview | Bases (core plugin) table or card views | 建议 |
| cross-chapter argument map | Canvas (`.canvas`, embeddable) | 慎用 |
| machine-only notes | `%%…%%` | 慎用 |

## Official callout types (with aliases)

`note` · `abstract` (`summary` `tldr`) · `info` · `todo` · `tip` (`hint` `important`) · `success` (`check` `done`) · `question` (`help` `faq`) · `warning` (`caution` `attention`) · `failure` (`fail` `missing`) · `danger` (`error`) · `bug` · `example` · `quote` (`cite`)

- `-` after the type collapses it, `+` expands it by default: `> [!quote]- Key quote 4`.
- Custom title: `> [!tip] Any title`; a callout with no body is title-only.
- An unrecognised type falls back to `note` — a typo doesn't error, it silently changes the look.
- Type identifiers are case-insensitive.

## Four upgrades worth adopting

**1. Block ids on quote blocks — citation precision from section to sentence.**
Add `^q-jianjidan` on its own line after a quote block (lowercase letters, digits, dashes only), then cite it as `[[我的学术之路#^q-jianjidan]]`. Narrower than `#§n`, and a reader lands on the sentence rather than the section.
Costs: block references are Obsidian-only syntax; the docs explicitly do not support linking to the *interior* of a quotation, callout, or table, only the whole block; and when a quote block is rewritten the id must move with it.

**2. Transclusion instead of re-quoting — `![[page#^block-id]]`.**
A `concepts/` page doesn't retype a quotation; it embeds the block already verified `✓` on the source page. This is the only way to *structurally* eliminate misquotation downstream: the concept page holds no copy, so it has nothing to mistype.
Costs: embedded content isn't editable in place; embed heavily and a reader loses track of whose words they're reading.

**3. Embed a PDF page — `![[book.pdf#page=42]]`.**
For a PDF source this removes the figure problem entirely: no extraction, no gamble on whether mermaid can draw it.
Caveat: the PDF must live inside the vault (a file in `~/Downloads` cannot be embedded). This is the one suggestion that puts a large file next to `raw/`, so it needs its own decision about where it lands.

**4. Bases over frontmatter — turn properties into a ledger.**
`publish:` and `cores:` are already written. Add `status:`, `chapter_id:`, `quotes_verified: 39/39` and a Base gives you "which chapters are ingested" and "which pages still carry ⚠" without grepping.
Caveat: Bases reads YAML properties, so sloppy types (`quotes_verified` sometimes a string, sometimes a number) scatter the view.

## 慎用

- **`%%comments%%`** don't render, so a human can't see them — and this wiki's rule is that *where the agent stopped must be visible where the human starts reading*. Machine notes belong in `log.md`.
- **HTML** — Obsidian does not render Markdown inside HTML tags; `**bold**` inside `<div>` stays literal.
- **Canvas** — a beautiful cross-chapter argument map, but the content then lives in two places (canvas and source pages) and will drift. Only for a one-off global summary.

## Two that would change current contracts (awaiting your call)

1. **Block-id citations** loosen "cross-page links target `#§n` only": `#§n` guarantees stability, `#^block-id` guarantees precision. A defensible split is `#§n` for `concepts/` / `persons/` (durable), `#^block-id` inside a source page and for its key quotes.
2. **PDF page embeds** require the PDF to sit inside the vault, which differs from today's "`raw/` is read-only and holds only `book-info.md`". It needs an explicit home.
