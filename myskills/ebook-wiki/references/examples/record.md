# Example — `record`

**Situation**: a chapter that must be *looked up* later — definitions, numbers, dates, names, formulas. This is the lookup layer of the spine. Slot schema in [cores/record.md](../cores/record.md).

## It looks like this

````md
## Entries
- **Dates**: reads philosophy at Oxford in the late 1920s-early 1930s; takes a teaching post in
  philosophy in 1932; serves as a British army officer during the Second World War. (§1, §3)
- **The Vienna Circle**: Russell's students, influenced by Carnap, Wittgenstein and Schlick; their
  standard is that the meaning of a proposition is the way it can be verified. (§1)
- **Oxford philosophy**: began at evening gatherings at Berlin's house; attendees included
  A. J. Ayer, J. L. Austin and Stuart Hampshire. (§1)
- **The number of values**: not infinite. Berlin writes "74 or 122 or 26" — the number does not
  matter, finiteness does. (§8)
- **Stalin, "engineers of human souls"**: the phrase comes from Stalin's 26 October 1932 remarks at
  Gorky's house on the role of Soviet writers. (ed. note) (§10)

## Terms
- **return to empiricism**: knowledge does not outrun experience. See [[wiki/persons/Russell and Moore|Russell and Moore]].
- **[[wiki/concepts/verificationism|verificationism]]**: the meaning of a proposition is the way it can be verified.
- **Herder's centre of gravity** (*Schwerpunkt*): every culture has its own frame of reference; the world is a large garden. See [[wiki/persons/Herder|Herder]].
- **[[wiki/concepts/two concepts of liberty|negative liberty]]**: "liberty from …" — count the doors.
  **positive liberty**: "liberty to …" — ask who steers.
````

## When the chapter is a classification system

A logic or grammar chapter produces no prose entries; it produces a grid and formulas. Same core, different rendering:

```md
## Entries
| Form | Proposition | Symbolic representation |
|---|---|---|
| A | All S is P | $S \bar P = 0$ |
| E | No S is P | $S P = 0$ |
| I | Some S is P | $S P \neq 0$ |
| O | Some S is not P | $S \bar P \neq 0$ |

Distributed terms: subject distributed in A and E; predicate distributed in E and O.
```

## Tricks used here

| What you're showing | Use |
|---|---|
| anything that must stay literal | `## Entries`: definitions, numbers, dates, names, formulas, each with its `§` |
| how *this chapter* uses a term | local `## Terms` (what it is, not why it matters) + links to `wiki/concepts/` |
| the book's precision | copy it exactly — `"74 or 122 or 26"` must not become "a number of values" |
| an editor's addition | mark it `(ed. note)` and keep it visually separate from the author's words |
| a classification system, not prose | a grid table, e.g. Form / Proposition / Symbolic representation |
| derivations in a logic or maths book | `$$…$$` with `\begin{align*}`; try experimental mermaid (e.g. `venn-beta`) before relying on it |

## Variants

| Material | What changes |
|---|---|
| mostly definitions and terms | `## Entries` + `## Terms`, with the division of labour stated |
| mostly numbers and formulas | entries carry the exact figures; derivations go in `$$…$$` blocks |
| a classification system (logic, linguistics) | a grid table replaces long entries |
| conceptual, few checkable facts | keep `## Terms` only; omit `## Entries` |
| pure prose insight, nothing checkable | `record` should not be declared — fix the book's conventions block instead |

## Anti-patterns

**① Padding an empty slot.** A chapter with no checkable facts gets a few vague "key points" to fill `## Entries`. That means `record` should not have been declared — fix `## How to read` in `AGENTS.md`, don't invent content. An empty declared core is this core's only real failure mode.

**② The local term table copying the global definition.** Pasting the whole of `wiki/concepts/pluralism.md` into `## Terms` gives one definition two homes, and every future edit will miss one. The local table answers "what did *this chapter* mean by it"; link to the concept page for the global answer.

**③ Two kinds of source in one entry.** "Stalin used the phrase (ed. note)" and "Berlin borrows Stalin's phrase" written as one item. Which words are the author's and which are the editor's is precisely why this page exists; merged, verification becomes impossible.

**④ Losing precision or qualifiers.** "74 or 122 or 26, and the number is not what matters, finiteness is" flattened to "there are finitely many values". The qualifier is part of the claim, not decoration — Berlin's hedge is often the point.

## On table headers in a Chinese book

Headers here are English because the sample is. A Chinese page uses `原句首 8 字 / 出处 / 省略 / 结果` and `场景 / 好处 / 代价 / 何时别用`; the mapping for every spine literal is in [LANGUAGE](../LANGUAGE.md).
