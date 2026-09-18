# Core: argue

**Promise**: after reading the page you can check whether each conclusion holds — without re-reading the source.
**Example**: [examples/argue.md](../examples/argue.md).

Chinese-book block names, table headers and inline notation: see [LANGUAGE](../LANGUAGE.md).

**Opening slot**: `## Skeleton` — the whole chain of conclusions on one screen (mermaid `flowchart TD`, or an arrow list when the chain is linear).

Per argument, a top-level block:

```md
## Argument n: <title>

- §: <§section> | type: deduction / counterexample reductio / incompatibility / elimination / cost argument / conceptual clarification
- **C**: <conclusion, one sentence, falsifiable>
- G:
  - G1 [verbatim · <role>] (〈Chapter〉§section):
    > <verbatim quote>
  - G2 [paraphrase · <role>] (〈Chapter〉§section): <paraphrase, no quote block>
- **W**:
  - W1 [stated | reconstruction | mine]: <what licenses G → C>
- **I**: <the inference steps from G+W to C, naming the type>
- **S**: <which Gs carry the argument: `+` = joint (drop one and it collapses), `;` = independent. Name the inert ones — target's position, the author's self-description, clarifications — and say they carry nothing.>
- **R**: <what evidence would collapse this argument>
```

## Slot rules

- **C** must be falsifiable. "Pluralism is right" is not a conclusion; "monism loses its epistemological ground" is.
- **G** entries are numbered `G1…Gn`, each tagged `[verbatim]` or `[paraphrase]`, each carrying a location. `[verbatim]` entries obey the [quote protocol](../SPINE.md) and appear in `## Quote check`; `[paraphrase]` entries never use a `>` block.
- Ground roles: `target's position` (the view being quoted), `counterexample`, `author's own conclusion`, `clarification`, `corroboration`. Grounds that are target / self-description / clarification must be declared as carrying no support in **S**.
- **W** is the step most often smuggled in. If the source does not state it, it is `[reconstruction]` at best; if you added it, `[mine]` and claim it in the open questions.
- **I** writes the steps out *and* names the argument type. Splitting reasoning into steps is what makes a leap visible.
- **S** uses `+` for joint support and `;` for independent support, and says which grounds are inert.
- **R** is mandatory. An argument with no stated rebuttal is unfinished, not strong.
- A `[mine]` anywhere in the block adds `> [!warning] My own addition` at that point.

## Notes

- Do not merge two arguments into one block because the source runs them together. If **S** would need two different joint sets, they are two arguments.
- When a conclusion is deliberately weaker than it looks ("monism **has no warrant**", not "monism is false"), keep that restraint in **C** — it is usually the point.
