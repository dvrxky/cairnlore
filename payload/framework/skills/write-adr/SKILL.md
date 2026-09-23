---
name: write-adr
description: Record ONE architectural decision immutably (context, options, decision, consequences). FIRES AUTOMATICALLY (no request needed) when a dependency or service boundary changes, a persisted schema or public contract changes, something moves between sync and async, data ownership shifts, a new pattern appears, or you catch yourself writing "we could either X or Y".
---

# write-adr

One decision per ADR. If you are writing "and we also decided", stop and write a second
ADR.

An ADR is immutable once its status is `accepted`. To change the decision, write a NEW
ADR that supersedes it by number and mark the old one `superseded by NNN`. Never edit an
accepted decision in place. This is the one place the framework keeps backward-looking
content, and R18 permits it: an ADR records a decision and its rationale, not a chronicle
of how the framework evolved.

- **triggers:** fires automatically (R22) on the `write-adr` trip-wire conditions in AGENTS.md section 13.2; no request needed
- **preconditions:** the project has a subtree under `knowledge/projects/`; if not, run `bootstrap-project` first

## Steps

1. Determine the next number: list `knowledge/projects/<project>/adr/`, take the highest
   `NNN` and add one. Zero-pad to three digits.
2. Name the decision in a single sentence. If you cannot, it is more than one decision.
3. Capture the options that were genuinely considered, each with its real trade-off. An
   ADR with one option is not a decision, it is a note.
4. Write to `knowledge/projects/<project>/adr/<NNN>-<slug>.md`.
5. Link the ADR from the spec that triggered it (`Related ADRs:` line).

## Template

```markdown
# NNN. <decision in one sentence>

Status: proposed | accepted | superseded by <NNN>
Date: YYYY-MM-DD
Project: <project>
Related spec: <slug>

## Context
The forces at play. What constraint, requirement, or problem forced a choice. Cite
`path/to/file:line` for anything asserted about existing code.

## Options considered
### A. <option>
Trade-off: what it costs, what it buys.
### B. <option>
Trade-off: ...

## Decision
The option chosen, stated flatly. "We will ..."

## Consequences
What becomes easier. What becomes harder. What is now locked in and what it would cost
to reverse. Include the consequences you dislike; an ADR listing only upsides is
worthless.
```

## Rules

- ASCII prose (R10). No em dashes. A diagram in a fenced block keeps its own characters.
- Cite from disk, never from memory (R6).
- If the decision turns out wrong later, that is a NEW ADR, not an edit. The wrong
  decision and its rationale stay readable, because the reasoning is the value.

## Validation

- Exactly one decision is recorded; a second decision means a second ADR.
- The number is one higher than the highest existing ADR for this project.
- Options considered include the one that was rejected, with why.
- The ADR is not edited after acceptance; a change means a new ADR that supersedes it.

## Example prompts

- `"record this decision"`
- `"why did we choose this, write it down"`
