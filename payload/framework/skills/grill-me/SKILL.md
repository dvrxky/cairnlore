---
name: grill-me
description: Interrogate a plan, spec, or design branch by branch until every decision is resolved and the remaining assumptions are named. Fires automatically at the end of gate 1 and gate 2 (AGENTS.md section 12), after two unconfirmed assumptions in a row, or when a one-sentence request implies a week of work. Also runs on request when the user says "grill me", "stress-test this", or "poke holes in this plan".
---

# grill-me

> The gates in section 12 both end here. A spec that was never grilled is a guess with
> formatting, and a plan that was never grilled is a list of things that sounded fine.

- **triggers:** fires automatically (R22) at gate 1 and gate 2, after two assumptions in a row without confirmation, or when a one-sentence request implies a week of work; also `"grill me"`, `"stress-test this"`, `"poke holes in this"`
- **preconditions:** there is a draft to attack (requirements, a spec, or a plan). With nothing drafted, draft it first, then grill.

## Steps

1. Walk the decision tree branch by branch. Resolve the dependencies between decisions
   one at a time; never open a second branch while the first is unresolved.
2. For every question, give your own recommended answer and the reason for it. A question
   without a recommendation moves work back onto the user for nothing.
3. If a question can be answered by reading the code, read the code instead of asking
   (R6). Only ask what the code cannot tell you.
4. Name every assumption you are still carrying. Each one is either confirmed by the user,
   verified from disk, or written into the artefact tagged `[inferred]` (R25).
5. Attack the edges explicitly: what happens on failure, on retry, on empty input, on
   concurrent callers, and at the boundary the spec does not mention.
6. Stop when no branch is open and no unnamed assumption remains. Say so in one line, then
   return to the gate that called you.

## Validation

- Every open branch is closed, or explicitly deferred with the reason recorded.
- Every remaining assumption is tagged `[inferred]` in the artefact (R25).
- No question was asked that the code already answered.
- Every question carried a recommendation.

## Example prompts

- `"grill me"`
- `"stress-test this plan"`
- `"poke holes in this design before I build it"`

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
