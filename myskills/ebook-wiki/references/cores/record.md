# Core: record

**Promise**: after reading the page you can look things up without re-reading the chapter.
**Example**: [examples/record.md](../examples/record.md).

Chinese-book block names: see [LANGUAGE](../LANGUAGE.md).

```md
## Entries
- **<term / figure / date / formula>**: <what it is, with §>
  - <sub-entry when one term needs structure>

## Terms
- **<local term>** (<gloss>): <what this chapter means by it>. See [[wiki/...|…]].
```

## Slot rules

- **Entries** holds what must be exact: definitions, numbers, dates, names, formulas, enumerations. Each entry carries the `§` it comes from. Numbers keep the book's unit and precision; never round silently.
- **Terms** defines what *this chapter* means by a term — "what it is, not why it matters". It is the local view: the term as introduced here, plus links to the global pages.
- `wiki/concepts/` and `wiki/persons/` remain the **global** authority. The local table answers "what did this chapter mean by it"; the concept page answers "what does the book mean by it". Never paste the global definition into the table — link it.
- A term the wiki does not track still gets a row if the chapter leans on it; a term with no chapter-specific sense does not get one.

## Notes

- Required slot: Entries. Terms when the chapter introduces terms the wiki tracks, or gives an established term a local sense.
- Do not restate the `### §n` record here. The record is a narrative of the chapter; entries are the lookup layer of things that must not be paraphrased.
- If the chapter's real output is prose insight with no exact facts, this core's slots stay empty and the core should not have been declared — that is a setup mistake to fix in the book's conventions block, not a gap to fill.
