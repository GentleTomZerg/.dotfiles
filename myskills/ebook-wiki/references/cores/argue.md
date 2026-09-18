# Core: argue

**Promise**: after reading the page you can check whether each conclusion holds — without re-reading the source.

**Opening slot**: `## Skeleton` — the whole chain of conclusions on one screen (mermaid `flowchart TD`, or an arrow list when the chain is linear).

**Blocks**: one per argument, in the Toulmin layout — **C**laim, **G**rounds, **W**arrant, **R**ebuttal — plus two slots this wiki adds, **I** (the inference steps) and **S** (which grounds carry the claim):

```md
## Argument n: <title>

- §: <§section> | type: deduction / counterexample reductio / incompatibility / elimination / cost argument / conceptual clarification
- **C**: <the claim, one sentence, falsifiable>
- G:
  - G1 [verbatim · <role>] (〈Chapter〉§section):
    > <verbatim quote>
  - G2 [paraphrase · <role>] (〈Chapter〉§section): <paraphrase, no quote block>
- **W**:
  - W1 [stated | reconstruction | mine]: <what licenses G → C>
- **I**: <the steps from G+W to C, naming the argument type>
- **S**: <which Gs carry the argument: `+` = joint (drop one and it collapses), `;` = independent; name the inert ones>
- **R**: <what evidence would collapse this argument>
```

## Slot rules

- **C** must be falsifiable. "Pluralism is right" is not a claim; "monism loses its epistemological ground" is.
- Each **G** is numbered, tagged `[verbatim]` or `[paraphrase]`, and carrying a location. `[verbatim]` obeys the [quote protocol](../SPINE.md) and appears in `## Quote check`; `[paraphrase]` never takes a `>` block. Roles: `target's position` (the view being quoted), `counterexample`, `author's own conclusion`, `clarification`, `corroboration` — and target, self-description and clarification carry no support, which **S** must say outright.
- **W** is the step most often smuggled in. A warrant the source does not state is `[reconstruction]` at best; one you added is `[mine]`, claimed in the open questions.
- **I** writes the steps out *and* names the type. Splitting the reasoning into steps is what makes a leap visible.
- **S** uses `+` for joint support and `;` for independent support, and names which grounds are inert.
- **R** is mandatory — an argument with no stated rebuttal is unfinished, not strong.
- Two arguments the source runs together stay two blocks, unless one joint set covers both: if **S** would need two different joint sets, they are two arguments.
- Restraint in **C** is usually the point: "monism **has no warrant**" is not the same claim as "monism is false", and the difference is the finding.
