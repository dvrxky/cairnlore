---
name: close-task
description: Close an in-progress task journal in the hub. Fills Outcome, promotes durable lessons to knowledge files (via the promote-lesson-to-knowledge skill), sets journal status to Done, and surfaces the commit message. Use when the user says "close the task", "close journal", "wrap up the task", "mark task done", or "finish the task".
---

# Skill: Close a task (close the journal, promote lessons)

> Closes the per-task journal opened by `start-task`. Promotes any durable lesson still
> in the "Lessons and gotchas (in-flight)" section into the right knowledge file (R3),
> fills Outcome, sets status `Done`, and hands you a commit message. Hub-only, same
> commit rules as everything else (AGENTS.md section 6).

- **triggers:** close the task, close journal, wrap up the task, mark task done, finish the task, complete the task
- **preconditions:**
  - There is an open task journal for the current work with status `In progress` under
    `HUB_ROOT/journal/` or `HUB_ROOT/journal/projects/<project>/`.
  - The task's implementation is genuinely finished; tests pass; no active TODOs remain
    (or they are recorded under "Open questions / TODO" for a follow-up).

## Steps

1. Find the journal: search `HUB_ROOT/journal/` and `HUB_ROOT/journal/projects/*/` for a
   journal with status `In progress` matching the current task's slug or link. If more
   than one candidate exists, ask the user which (R2, R4). If none exists, refuse - a
   task without a journal was never properly opened; use `start-task` first, or record
   a retro journal explicitly.
2. If the journal's `link:` field points at an issue tracker, re-check that issue's
   current state and surface (but do not resolve) any divergence between the journal's
   status and the tracker's. If the hub provides a tracker-sync skill, run it on this one
   journal; otherwise report the divergence in one line.
3. Fill the **Outcome** section: what shipped, what changed, final state. Cite `path:line`
   for any code claim, verified from disk this session (R6).
4. Walk the **Lessons and gotchas (in-flight)** section. For each entry not already tagged
   `[promoted -> ...]`, decide:
   - Durable (a fact, convention, or fix that any future session should know)? Run the
     `promote-lesson-to-knowledge` skill on it. Update the tag to
     `[promoted -> <knowledge file>:<section>]`.
   - Task-specific / one-off? Leave in the journal only.
5. Fill the **Promoted to knowledge** section at the bottom: bullet-list the promotions
   with their destination file and anchor.
5a. **Refine `ESSENTIALS.md` (R19).** Open it and do all three:
   - PROMOTE: any fact that has now been load-bearing on two or more separate tasks earns
     a line (the distilled trigger plus a pointer, never the detail).
   - EVICT: any line that did not influence a decision recently comes out. It stays in
     `knowledge/`; it just stops being always-loaded.
   - COMPRESS: merge any two lines that say overlapping things.
   The file has a SOFT TARGET of 40 items. Past it, demote the lowest-value ones. A
   turn that grows ESSENTIALS without cutting anything is an incomplete close-task.
5b. If this task had a spec at `knowledge/projects/<project>/specs/<slug>.md`, update its
   `Status:` (usually to `implemented`) and reconcile any requirement that changed during
   implementation. If an architectural decision was made mid-flight and never recorded,
   write it now via `write-adr`.
6. Move any unresolved item under **Open questions / TODO** to a follow-up (either open
   a new journal for it via `start-task`, or leave the item in place and set the journal
   status to `Blocked` instead of `Done`, per user's call).
7. Set the front-matter `status:` field to `Done` (or `Blocked` if step 6 forced it).
8. Handle commits per AGENTS.md section 6:
   - Code changes in the project repo: NEVER commit; surface a code-repo commit message.
   - Hub changes: commit and push (R15), echoing the message in the response.

## Validation

- The journal's `status:` line reads `Done` (or `Blocked` with an explicit reason).
- The `Outcome` section is non-empty and cites disk-verified `path:line` for any code
  claim.
- Every "in-flight lesson" from step 4 is either tagged as promoted or explicitly marked
  task-specific.
- `Promoted to knowledge` bullets link to real destinations that actually gained content
  this session.

## Guardrails

- Do NOT edit prior lessons/decisions/clarifications in the journal - append or annotate
  only. The journal is append-only during work; at close you add Outcome and annotate
  promotions, nothing else.
- Do NOT invent an Outcome. If work stopped mid-flight, set `Blocked` with the blocker.
- Do NOT create a duplicate journal for the same task (R4).
- Do NOT delete the journal after close. It is the historical record.

## Example prompts

- "close the task"
- "wrap up TICKET-1234"
- "mark the killswitch cleanup done"
- "close the journal - work stopped, we're blocked on the CBR mirror decision"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). Code-repo commits forbidden; the hub auto-commits and pushes (R15).
