# Core: argue

**Promise**: after reading the page you can check whether each conclusion holds — without re-reading the source.

Toulmin gives **C**laim, **G**rounds, **W**arrant. This wiki adds three slots: **I** (the inference steps), **S** (which grounds carry the claim), **R** (the falsifier).

```md
## Skeleton
<the whole chain of conclusions on one screen: mermaid `flowchart TD`, or an arrow list when the chain is linear>

## Argument n: <title>

- §: <the section the argument runs in>
- **C**: <the claim, one sentence, falsifiable>
- G:
  - G1 [verbatim · <role>] (〈Chapter〉§section):
    > <verbatim quote>
  - G2 [paraphrase · <role>] (〈Chapter〉§section): <paraphrase, no quote block>
- **W**:
  - W1 [stated | reconstruction | mine]: <what licenses G → C>
- **I** (<type>): <the steps from G + W to C, written out>
- **S**: <which Gs carry the argument — `+` joint, `;` independent — and which are inert>
- **R**: <what evidence would collapse the claim>
```

Required: every slot — **Skeleton**, then **C**, **G**, **W**, **I**, **S**, **R** in each argument block.

## Slot rules

- **C** — falsifiable, one sentence. "Pluralism is right" is not a claim; "monism loses its epistemological ground" is. Restraint is usually the finding: "monism **has no warrant**" is not the claim "monism is false", and the difference is the point.
- **G** — numbered, tagged `[verbatim]` or `[paraphrase]`, each with a location. `[verbatim]` obeys the [quote protocol](../SPINE.md) and appears in `## Quote check`; `[paraphrase]` never takes a `>` block. Roles: `target's position` (the view being quoted) · `counterexample` · `author's own conclusion` · `clarification` · `corroboration`. Target, self-description and clarification carry no support — **S** must say so outright.
- **W** — what licenses G → C, and the step most often smuggled in. A warrant the source does not state is `[reconstruction]` at best; one you added is `[mine]`, claimed in the open questions.
- **I** — the steps from G + W to C, written out *and* named: `deduction` · `counterexample reductio` · `incompatibility` · `elimination` · `cost argument` · `conceptual clarification`. Writing the steps out is what makes a leap visible.
- **S** — `+` for joint support (drop one and it collapses), `;` for independent support, and name the inert grounds. Two arguments the source runs together stay two blocks unless one joint set covers both: **if S would need two different joint sets, they are two arguments.**
- **R** — mandatory, and read as the *falsifier*, not as Toulmin's exception: what evidence would collapse the claim. An argument with no R is unfinished, not strong.
