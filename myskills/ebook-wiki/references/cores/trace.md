# Core: trace

**Promise**: after reading the page you can follow who did what, in what order, and why — and see where the causal links are the agent's guess rather than the book's claim.

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

- **Causal chain** tags every link. `[stated in the book]` only when the source asserts the causation; otherwise `[my inference]` — the slot most likely to turn into undetected storytelling, since narrative supplies causation for free.
- **Positions** carries a source per row so each entry is checkable. *position* is the person's view **as this chapter presents it**; a view the book disagrees with is still recorded as theirs.
- **Timeline** orders by event, not by narrative reveal. Where the book withholds something, say so rather than back-filling the date.
- A diagram of a sequence belongs in the timeline; this core has no Diagram or Code slot.

## Notes

- Required slots: Positions, Causal chain. Timeline when the chapter has dates or a sequence.
- Names resolve to `wiki/persons/`; only roles and positions *as this chapter has them* stay on the page; lineage and dates belong in the person page.
- A chapter that is mostly argument with a historical opening is `argue` with a `trace` opening section — not both cores competing for the same material.
- When the source says it does not know why something happened, the page records the not-knowing.
