# Core: trace

**Promise**: after reading the page you can follow who did what, in what order, and why — and see where the causal links are the agent's guess rather than the book's claim.
**Example**: [examples/trace.md](../examples/trace.md).

Chinese-book block names and table headers: see [LANGUAGE](../LANGUAGE.md).

**Opening slot**: `## Skeleton` — one screen of the sequence (mermaid `timeline`, or a `flowchart LR` when the point is divergence rather than chronology).

```md
## Skeleton
<mermaid timeline>

## Timeline
<mermaid timeline, or a table when entries need more than a date and a phrase>

## Positions
| person | position | opposed by | source |
|---|---|---|---|

## Causal chain
<mermaid or arrow list; every link tagged [stated in the book] or [my inference]>

## Links to other chapters
<which earlier/later chapters this connects to, and how>
```

## Slot rules

- **Causal chain** tags every link. `[stated in the book]` only when the source asserts the causation; otherwise `[my inference]`, which carries the same obligation as `[mine]` — claim it in the open questions. This is the slot most likely to turn into undetected storytelling.
- **Positions** carries a source per row so each entry is checkable. *position* is the person's view **as this chapter presents it**; a view the book disagrees with is still recorded as theirs.
- **Timeline** orders by event, not by narrative reveal. If the book withholds something, say so rather than back-filling the date.
- The **Diagram** and **Code** slots are not part of this core; a diagram of a sequence belongs in the timeline.

## Notes

- Required slots: Positions, Causal chain. Timeline when the chapter has dates or a sequence.
- Names resolve to `wiki/persons/`; only the roles and positions *as this chapter has them* stay on the page.
- A chapter that is mostly argument with a historical opening is `argue` with a `trace` opening section — not both cores competing for the same material.
