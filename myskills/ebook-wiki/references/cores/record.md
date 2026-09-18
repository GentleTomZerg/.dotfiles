# Core: record

**Promise**: after reading the page you can look things up without re-reading the chapter.

```md
## Entries
- **<term / figure / date / formula>**: <what it is, with §>
  - <sub-entry when one term needs structure>

## Terms
- **<local term>** (<gloss>): <what this chapter means by it>. See [[wiki/...|…]].
```

## Slot rules

- **Entries** holds what must be exact: definitions, numbers, dates, names, formulas, enumerations — each carrying the `§` it came from. Numbers keep the book's unit and precision; never round silently.
- **Terms** defines what *this chapter* means by a term: "what it is, not why it matters" — the local view, plus links to the global pages.
- `wiki/concepts/` and `wiki/persons/` remain the **global** authority: the local table answers "what did this chapter mean by it", the concept page answers "what does the book mean by it". Never paste the global definition into the table — link it.
- A term the wiki does not track still gets a row if the chapter leans on it; a term with no chapter-specific sense does not.

## Notes

- Required slot: Entries. Terms when the chapter introduces terms the wiki tracks, or gives an established term a local sense.
- The `### §n` record is a narrative of the chapter; entries are the lookup layer of things that must not be paraphrased. They never restate each other.
- A chapter whose real output is prose insight with no exact facts has no entries: this core should not have been declared, and the fix is in the book's conventions block, not a gap to fill.
