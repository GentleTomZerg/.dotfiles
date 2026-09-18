# Core: explain

**Promise**: after reading the page you can re-derive how the thing works, and say when it breaks.

**Opening slot**: `## Skeleton` — one screen showing the flow (mermaid `flowchart` / `sequenceDiagram` / `stateDiagram`).

````md
## Skeleton

<mermaid flow>

## What it solves

<1-3 sentences: the problem, and what the book's answer buys>

## Mechanism

<prose, step by step. Name the key invariant, or the two things that must hold.>

## Diagram

<mermaid, or prose + `see figure n-m in the book` per the rule below>

## Code

```<lang>
<verbatim excerpt>
```
````

<provenance: listing number or file:line as printed>

## Trade-offs

| scenario | benefit | cost | when not to use |
| -------- | ------- | ---- | --------------- |

Required: **Mechanism**, **Trade-offs**. **Code** and **Diagram** only when the chapter has them.

## Slot rules

- **Mechanism** is prose, not a list of bullets. The test: could a reader re-derive the behaviour from it without the book? Bullets that restate the headings fail that test.
- **Trade-offs** must name a *cost* and a *when not to use*. A row with only benefits is marketing, not a trade-off.
- **Code** quotes the book only. Fence it with the language and cite the provenance as printed (`listing 7-2`, or `path/file.c:41` when the book prints one). Do not fetch the book's repo to complete an excerpt — if the printed fragment does not make the mechanism checkable, **ask the human** for the file.
- **Diagram** — mermaid first, always. If mermaid cannot express the figure (a photograph, a hand-drawn architecture, a screenshot), write what the figure shows in prose, cite `see figure n-m in the book`, and ask the human. A human-supplied image goes in `wiki/assets/<book>/` and is linked from the page.

## Notes

- If the book gives several mechanisms that interact, use one `## Mechanism` per mechanism and let `## Skeleton` carry the interaction.
- Version-sensitive facts (API names, defaults, benchmarks) get the book's edition or date attached — this is the material most likely to rot.
