# Core: explain

**Promise**: after reading the page you can re-derive how the thing works, and say when it breaks.

**Opening slot**: `## 骨架` — one screen showing the flow (mermaid `flowchart` / `sequenceDiagram` / `stateDiagram`).

```md
## 它解决什么问题
<1-3 sentences: the problem, and what the book's answer buys>

## 机制
<prose, step by step. Name the key invariant or the two things that must hold.>

## 图
<mermaid, or prose + `见原书 图 n-m` per the rule below>

## 代码
```<lang>
<verbatim excerpt>
```
<provenance: listing number or file:line as printed>

## 取舍表
| 场景 | 好处 | 代价 | 何时别用 |
|---|---|---|---|
```

## Slot rules

- **机制** is prose, not a list of bullets. The test: could a reader re-derive the behaviour from it without the book? Bullets that restate headings fail this test.
- **取舍表** must name a *cost* and a *when not to use*. A row with only benefits is marketing, not a trade-off.
- **代码** quotes the book only. Fenced with the language, provenance cited as printed (`listing 7-2`, or `path/file.c:41` when the book prints one). Do not fetch the book's repo to complete an excerpt — if the printed fragment does not make the mechanism checkable, **ask the human** for the file.
- **图** — mermaid first, always. Never extract images from the EPUB. If mermaid cannot express the figure (a photograph, a hand-drawn architecture, a screenshot), write what the figure shows in prose, cite `见原书 图 n-m`, and ask the human. A human-supplied image goes in `wiki/assets/<book>/` and is linked from the page; `raw/` stays untouched.

## Notes

- Required slots: 机制, 取舍表. 代码 and 图 are required when the chapter has them, omitted otherwise (never an empty heading).
- If the book gives several mechanisms that interact, use one `## 机制` per mechanism and let `## 骨架` carry the interaction.
- Version-sensitive facts (API names, defaults, benchmarks) get the book's edition or date attached — this is the material most likely to rot.
