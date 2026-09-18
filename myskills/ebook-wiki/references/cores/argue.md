# Core: argue

**Promise**: after reading the page you can check whether each conclusion holds — without re-reading the source.

**Opening slot**: `## 骨架` — the whole chain of conclusions on one screen (mermaid `flowchart TD`, or an arrow list when the chain is linear).

Per argument, a top-level block:

```md
## 论证 n：<标题>

- 所涉§： <§节名> | 类型： 演绎 / 反例归谬 / 不兼容性 / 排除法 / 代价论证 / 概念澄清
- **C**： <conclusion, one sentence, falsifiable>
- G：
  - G1 [直引·<角色>]（〈章名〉§节名）：
    > <verbatim>
  - G2 [转述·<角色>]（〈章名〉§节名）： <paraphrase, no quote block>
- **W**：
  - W1 [原文直撑 | 合理重构 | 我的发挥]： <what licenses G → C>
- **I**： <the inference steps from G+W to C, naming the type>
- **S**： <which Gs carry the argument: `+` = joint (drop one and it collapses), `;` = independent. 靶子 / 自述 / 澄清 carry nothing — say so.>
- **R**： <what evidence would collapse this argument>
```

## Slot rules

- **C** must be falsifiable. "多元论是对的" is not a conclusion; "一元论失去认识论根基" is.
- **G** entries are numbered `G1…Gn`, each tagged `[直引]` or `[转述]`, each carrying a location. `[直引]` entries obey the [quote protocol](../SPINE.md) and appear in `## 引文核对`; `[转述]` entries never use a `>` block.
- Roles on grounds: `对方立场` (the target being quoted), `反例`, `结论自述`, `澄清`, `旁证`. Grounds that are 靶子 / 自述 / 澄清 must be declared as carrying no support in **S**.
- **W** is the step most often smuggled in. If the source does not state it, it is `[合理重构]` at best; if you added it, `[我的发挥]` and claim it in `疑问`.
- **I** writes out the steps *and* names the argument type. Splitting reasoning into steps is what makes a leap visible.
- **S** uses `+` for joint support and `;` for independent support, and says which grounds are inert.
- **R** is mandatory. An argument with no stated rebuttal is unfinished, not strong.
- A `[我的发挥]` anywhere in the block adds `> [!warning] 我的发挥` at that point.

## Notes

- Do not merge two arguments into one block because the source runs them together. If `S` would need two different joint sets, they are two arguments.
- When a conclusion is deliberately weaker than it looks ("一元论**无权主张**", not "一元论为假"), keep that restraint in **C** — it is usually the point.
