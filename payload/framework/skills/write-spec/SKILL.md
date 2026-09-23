---
name: write-spec
description: Gate 1 of spec-first delivery: produce a durable specification after grilling requirements. FIRES AUTOMATICALLY (no request needed) when a change alters observable behaviour, plausibly touches more than two files, implies a business rule not written in knowledge/, contains an unresolved "or", or forces a material assumption. Never emit a task list here.
---

# write-spec

Gate 1 of AGENTS.md section 12. The output is a SPEC, not a plan. A plan is checked off
and becomes worthless; a spec is what someone reads in nine months to understand why the
feature behaves the way it does.

Refuse to write implementation steps in this skill. If the user pushes for a plan, finish
the spec first, then hand off to gate 2.

- **triggers:** fires automatically (R22) on the `write-spec` trip-wire conditions in AGENTS.md section 13.2; no request needed
- **preconditions:** the project has a subtree under `knowledge/projects/`; if not, run `bootstrap-project` first

## Steps

1. **Draft the requirements** as you currently understand them. Short, blunt, numbered.
   State what you are assuming, explicitly.

2. **Grill.** Load `grill-me` and interrogate the user branch by branch until the
   requirements are thorough. Walk the decision tree, resolving dependencies between
   decisions one at a time. Rules:
   - If a question can be answered by reading the code, read the code. Do not ask.
   - Ask about the unhappy paths: empty, null, concurrent, partial failure, retry,
     backfill, rollback.
   - Ask what is explicitly OUT of scope. Non-goals prevent more rework than goals do.
   - Stop when a new question stops changing the answer.

3. **Identify architectural decisions.** Anything with lasting structural consequence
   (storage choice, sync vs async, new service boundary, contract change, data
   ownership) does NOT go in the spec body. Each one gets its own ADR via `write-adr`.
   The spec links to them.

4. **Write the spec** to `knowledge/projects/<project>/specs/<slug>.md` using the
   structure below. Create the `specs/` directory if absent.

5. **Confirm.** Show the user the spec path and the open questions that remain, if any.
   Then stop. Gate 2 (plan) is a separate, explicit step.

## Spec structure

```markdown
# Spec: <feature name>

Status: draft | agreed | implemented | superseded
Project: <project>
Related ADRs: <NNN-slug>, ...

## Problem
What is broken or missing, in one paragraph. Why it matters now.

## Requirements
Numbered, testable statements. "The system MUST ..." Each one verifiable.

## Business rules
The domain logic that is not obvious from the requirements. Include the WHY, and the
ticket or person that is the source of truth for each rule.

## Edge cases
The unhappy paths and what the system does in each. Empty, null, duplicate, out-of-order,
concurrent, partial failure, retry, rollback.

## Gotchas
Non-obvious constraints, upstream behaviour that cannot be changed, known traps. Cite
`path/to/file:line` where the constraint lives.

## Non-goals
What this explicitly does NOT do. The most valuable section in the document.

## Acceptance criteria
The checklist QA verifies against in gate 4. Written so someone else could run it.

## Open questions
Anything still unresolved, with who owns the answer. Empty when status is `agreed`.
```

## Rules

- Every factual claim about existing code carries a `path:line` verified from disk this
  session (R6).
- ASCII prose (R10); leave fenced blocks and diagrams untouched. Present tense, no
  history of how the design evolved (R18).
- When implementation later proves the spec wrong, the SPEC is updated first, then the
  code. Never let them silently diverge (R7, R17).
- On `close-task`, set the spec's Status and promote any load-bearing lesson into
  `knowledge/` and, if it earns a line, into `ESSENTIALS.md` (R19).

## Validation

- Every requirement has an acceptance criterion that can be checked without the author.
- Non-goals are explicit, not implied by omission.
- Every assumption that was not verified this session is tagged `[inferred]` (R25).
- No task list appears anywhere in the spec; that is gate 2.

## Example prompts

- `"spec this out"`
- `"before you write code, what are we actually building"`
