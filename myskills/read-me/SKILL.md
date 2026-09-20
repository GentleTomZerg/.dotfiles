---
name: read-me
description: Which reading skill fits your situation — the map of the loop, the on-ramps, and the boundaries.
disable-model-invocation: true
---

# Read me

You don't remember every skill, so ask. This maps the reading loop: what runs when, and what to reach for when you are not sure.

## The loop

Karpathy's three passes, which the whole vault is built around:

1. **Pass 1 — you read.** No skill. The one thing that is never delegated: a summary you did not read toward is a substitute for the read, not a preparation for it.
2. **Pass 2 — `/skill:ingest`.** One unit (a chapter, a section, a paper) becomes pages: a summary, integrated concept and entity pages, a comparison when it collides with something already read, candidate tests, and open questions. It ends with an interview — the candidates are the agent's guesses at what matters, and only you know which ones are right.
3. **Pass 3 — `/skill:query`.** You argue with what you read. Answers come with their sources and get **filed back** as pages, so nothing valuable dies in chat history.

Then, at whatever rhythm suits you:

- **`/skill:test-me`** — cold recall, graded against the source. A solid pass promotes *your* sentence onto the page; two failures mean the read did not take, and the fix is to re-read and re-ingest, not to be quizzed again. This is the only thing that proves you know it.
- **`/skill:synthesize`** — several sources on one topic become a comparison, and then, by grilling you, your position on it, with the case that breaks it.
- **`/skill:lint-wiki`** — every few ingests: contradictions, red links, orphans, stale claims, gaps. It also collects every open question and tells you what to read or settle next.

## On-ramps

A starting situation, and where it joins the loop.

- **A question with no reading behind it** → `/skill:query`. If the vault cannot answer it, it leaves an open question on the page it belongs to, which is a fine outcome.
- **A paper you must digest for work** → read it (a skim counts as pass 1 only if you say so), then `/skill:ingest`.
- **Two books disagree** → `/skill:ingest` the second one and accept the collision it reports, then `/skill:synthesize`.
- **You can't tell what you actually know** → `/skill:test-me`.
- **The vault feels untrustworthy** → `/skill:lint-wiki`.
- **A topic too big and foggy for one session** → `/skill:wayfinder`. It is domain-agnostic, and a big reading effort charts the same way an engineering one does: a map of decision tickets, resolved one at a time. It hands off to a plan, not to a wiki.
- **The topic is a skill, not knowledge** → `/skill:teach`. Reading builds knowledge; `teach` builds ability, with lessons and practice. They share the mission idea and nothing else.

## Underneath

Model-invoked skills that do a job *inside* the flows above, and are worth reaching for directly when the job is the whole task:

- **`/skill:research`** — reading legwork against primary sources in a background agent. A synthesis page that needs an idea's origins, or a query the vault cannot settle, is a research job. Its findings file back as pages.
- **`/skill:grilling`** — the interview primitive. `/skill:ingest` uses it for emphasis, `/skill:synthesize` for your position. Run it directly when the thing to sharpen is not a reading but a plan.
- **`/skill:prototype`** — for practice books, when the honest test is "try both designs on your real code" rather than "say which is better".
- **`/skill:obsidian-cli`, `/skill:obsidian-markdown`** — browsing and note mechanics. Obsidian is the IDE; you read the wiki there while the agent writes it.

## Phase boundaries

Between a reading session and whatever comes next:

- **Continue** — the default. Same source, next unit, with the interview's emphasis still in context.
- **`/clear`** — every skill here works off the vault, not the conversation, so clearing between units costs nothing.
- **`/skill:handoff`** — a new harness, a new directory, or a colleague.
- **`/skill:wait-what`** — when a page's prose has stopped making sense to you, in plain English with the vault's own vocabulary.

## The rules

Your vault's schema — `AGENTS.md` at the vault root — is the single source of truth for the conventions and the invariants, and it is yours to edit. Read it there; the short version is that pass 1 is yours, the agent writes the wiki while the sentence carrying an idea is yours, nothing is written without a source behind it, contradictions are flagged rather than overwritten, candidates are proposals you accept, and every session ends with a write.

## Precondition

**`/skill:setup-reading`** — run once before the first ingest: it scaffolds the vault, writes the schema every skill reads, and records your intent.
