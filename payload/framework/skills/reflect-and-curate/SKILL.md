---
name: reflect-and-curate
description: Close the self-improvement loop using execution feedback (ACE generate-reflect-curate). Update helpful/misled counters on playbook items, add what was missing, demote dead weight. FIRES AUTOMATICALLY at the end of any task, after any surprise or repeated failure, and whenever a turn contradicts an ESSENTIALS item. No request needed.
---

# reflect-and-curate

Implements AGENTS.md R24. Self-improvement comes from what actually happened, not from
opinion. Three roles, in order.

- **triggers:** fires automatically (R22) at the end of any task, after a surprise or a repeated failure, or when a turn contradicts an ESSENTIALS item; no request needed
- **preconditions:** `ESSENTIALS.md` is readable in the hub

## Steps

### 1. GENERATE - what happened

State plainly: what was attempted, what worked, what failed, and how many attempts each
took. Use the task journal if one is open. No interpretation yet.

### 2. REFLECT - grade the context

For every `ESSENTIALS.md` item that was in play this task, answer one question: did it
change a decision, and was that change correct?

| Outcome | Action |
|---|---|
| Item steered a decision correctly | `h` + 1 |
| Item was followed and led somewhere wrong | `m` + 1 |
| Item was present but irrelevant | leave it |
| You had to discover something that should have been known | candidate NEW item |
| You did something well that is not written anywhere | candidate NEW item |

Be honest about `m`. An item with `m` >= 2 is actively harmful and must be deleted or
rewritten with the specificity it was missing. Silently leaving a misleading item in the
playbook is the single fastest way to make the framework worse over time.

### 3. CURATE - apply deltas

Apply the smallest possible edits (R23). Never rewrite the file.

- **Add** a new item only if the fact would change a decision on a FUTURE task. Give it
  the next free id, `(h:0 m:0)`, one line, and a pointer to where the detail lives. Write
  the detail into `knowledge/` first; the playbook item is only the trigger.
- **Edit** an item to be MORE specific, never less. If you are tempted to generalise two
  items into one, stop: that is brevity bias and it destroys the value.
- **Demote** when the file exceeds its soft target of 40 items. Remove the line here; the
  detail stays in `knowledge/`. Demote by lowest `h`, oldest first. Demotion is not
  deletion of knowledge, only of always-loaded status.
- **Delete** any item with `m` >= 2 that you cannot make specific enough to be safe.

## Output

Report the deltas in one short block, nothing else:

```
Reflect: E-003 h+1 (spec gate caught a missing requirement), E-009 m+1 (rule was
ambiguous about code blocks).
Curate: +E-016 "poll rolloutState, not desiredCount" -> knowledge/aws.md#ecs
        ~E-009 clarified to exclude fenced code
        -E-011 demoted (h:0 after 30 tasks)
```

## Guardrails

- Never invent a counter change you cannot point to a turn for.
- Never add an item that restates a rule already in `AGENTS.md` verbatim; point at it
  instead.
- A task that genuinely taught nothing produces no deltas. Say so in one line. Manufacturing
  deltas to look productive corrupts the signal.

## Validation

- Every counter change names the turn that justified it.
- No item was made vaguer, and no two items were merged (R19).
- Items removed were removed because they were dead weight or `m` >= 2, never to hit a number.
- The hub is committed and pushed (R15).

## Example prompts

- `"what did we learn"`
- `"close the loop on this task"`
