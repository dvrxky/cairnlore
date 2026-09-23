---
name: capture-upstream
description: Produce a scrubbed, ready-to-paste block describing a framework improvement discovered on a machine that cannot push to the engine repo. FIRES AUTOMATICALLY whenever a durable improvement to the ENGINE (a rule, skill, or workflow, as opposed to project knowledge) is learned on a machine whose engine clone has no push access. No request needed.
---

# capture-upstream

The engine repo is pull-only on this machine (see `SETUP.md`). When you learn something
that should change the ENGINE rather than local knowledge, you cannot commit it here. So
hand the user a block they can paste into a session on the machine that owns the engine.

- **triggers:** fires automatically (R22); no request needed
- **preconditions:** the engine clone on this machine cannot push; the improvement is to a RULE, SKILL, or WORKFLOW, not to project knowledge

## When this fires vs when it does not

| Discovery | Goes to |
|---|---|
| A rule, skill, or workflow should change | HERE: capture-upstream |
| A fact about a project, service, or codebase | `knowledge/` locally, never upstream |
| A one-off fix with no reusable lesson | the journal, nothing more |

If you cannot state the improvement without naming a specific system, it is knowledge, not
engine. Keep it local.

## Steps

1. **State the delta.** Which file in the engine changes, and what the new or edited text
   is. Be concrete enough that the upstream session can apply it without guessing.

2. **Scrub.** Rewrite it so it contains none of:
   - organisation, client, or team names
   - service, repo, cluster, queue, or hostname identifiers
   - ticket prefixes or issue keys
   - internal URLs, account ids, ARNs, IP ranges
   - absolute paths that include a username or an org directory
   Replace each with a generic placeholder. If removing them destroys the lesson, the
   lesson is project knowledge and this skill does not apply. Stop and file it locally.

3. **Verify.** Re-read the scrubbed block and confirm every item in step 2 is absent.
   State the verification explicitly in the output. Do not skip this because the block
   "looks fine"; the whole point is that it is checked by construction.

4. **Emit the block** in the format below, as the LAST thing in the response, so it is
   easy to copy.

5. **Log it** in the task journal under `Upstream captures` so a later session can tell
   whether it was ever applied.

## Output format

```
UPSTREAM CAPTURE - paste into a session on the machine that owns the engine

File: <path within the engine repo>
Change: <add | edit | remove>

<the exact text to add or the precise edit to make>

Why: <one line, the evidence that motivated it>

Scrub check: no organisation or team names, no service or host identifiers, no ticket
prefixes, no internal URLs or account ids, no user-specific paths. Verified.
```

## Guardrails

- Never attempt `git push` on the engine clone here. The remote is deliberately disabled;
  trying and failing wastes a turn and teaches nothing.
- Never batch unrelated improvements into one block. One capture per change keeps the
  upstream commit clean and reviewable.
- If the same capture has been emitted before and never applied, say so rather than
  emitting it again silently.

## Validation

- The block names the exact engine file and the exact placement for every change.
- The block is ASCII prose (R10) and contains no project, organisation, or host identifiers.
- Nothing in the engine clone on this machine was edited.

## Example prompts

- `"capture this for upstream"`
- `"I cannot push the engine from here, export the change"`
