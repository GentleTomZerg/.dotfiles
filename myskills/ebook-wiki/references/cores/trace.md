# Core: trace

**Promise**: after reading the page you can follow who did what, in what order, and why — and see where the causal links are the agent's guess rather than the book's claim.

**Opening slot**: `## 骨架` — one screen of the sequence (mermaid `timeline`, or a `flowchart LR` when the point is divergence rather than chronology).

```md
## 时间线
<mermaid timeline, or a table when entries need more than a date and a phrase>

## 人物与立场表
| 人物 | 主张 | 与谁对立 | 出处 |
|---|---|---|---|

## 因果链
<mermaid or arrow list; each link tagged [书中明说] or [我的推断]>

## 与其他章的接口
<which earlier/later chapters this connects to, and how>
```

## Slot rules

- **因果链** tag every link. `[书中明说]` only when the source asserts the causation; otherwise `[我的推断]`, which is the same obligation as `[我的发挥]` — claim it in `疑问`. This is the slot most likely to turn into undetected storytelling.
- **人物与立场表** carries 出处 per row so each entry is checkable. 主张 is the person's position *as this chapter presents it*; a position the book disagrees with is still recorded as theirs.
- **时间线** orders by event, not by narrative reveal. If the book withholds something, say so rather than back-filling the date.
- **图** and **代码** slots are not part of this core; a diagram of a sequence belongs in `时间线`.

## Notes

- Required slots: 人物与立场表, 因果链. 时间线 when the chapter has dates or a sequence.
- Names resolve to `wiki/persons/`; only the roles and positions *as this chapter has them* stay on the page.
- A chapter that is mostly argument with a historical opening is `argue` with a `trace` opening section — not both cores competing for the same material.
