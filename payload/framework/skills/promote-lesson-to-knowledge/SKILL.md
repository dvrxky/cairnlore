---
name: promote-lesson-to-knowledge
description: Take a lesson, fact, fix, or convention discovered during a task and record it in the correct hub knowledge file, in the same turn it was learned. Formalizes the R3 self-organizing loop step from the framework's AGENTS.md. Use when the user says "promote this lesson", "record this fix", "add to known-issues", "add to conventions", "capture this convention", or when closing a task via `close-task`.
---

# Skill: Promote a lesson into knowledge (the R3 loop)

> Framework rule R3 says the moment you learn something durable, record it in the right
> knowledge file BEFORE moving on. This skill is the concrete procedure for doing that
> without duplicating an entry (R4) or writing to the wrong file (section 4
> classification).

- **triggers:** promote this lesson, record this fix, capture this convention, add to known-issues, add to conventions, add to config knowledge, log this gotcha, remember this for next time
- **preconditions:**
  - A durable fact, fix, convention, or config detail has just been discovered.
  - The current context tells you which project it belongs to (or that it is
    cross-project).

## Steps

1. **Classify** the discovery against AGENTS.md section 4:

   | Discovery | Destination file |
   |---|---|
   | Error + its fix, tool misbehaviour, failed approach | `known-issues.md` |
   | Convention, pattern, rule, mapping, domain fact | `conventions.md` |
   | Build path, env, version, setup, config fact | `config.md` |
   | New component / service / module worth mapping | `INDEX.md` (component map) |

2. **Scope**: is it project-specific or cross-project?
   - Project-specific: destination is
     `HUB_ROOT/knowledge/projects/<project>/<file>.md`.
   - Cross-project (applies to multiple <your-domain> projects, e.g. Kafka lag alarm patterns):
     destination is `HUB_ROOT/knowledge/<file>.md`. If no matching cross-project file
     exists, create one (R4 requires searching first - see step 3).

3. **Search first (R4):** grep the destination file (and any obviously related file) for
   the topic keywords. If an existing entry covers this:
   - Append to that entry, expanding it. Do not create a new one.
   - If the existing entry is thinner than what you just learned, replace it in place
     with the richer version and note the merge in the journal.
   - If the entry is out of date (states behaviour that no longer holds), rewrite it with
     the new truth and add a one-liner about what changed (R7: surface, do not silently
     reconcile - if the spec is contradictory to the reality, flag it).
   If no existing entry covers it, jump to step 5.

4. Choose the provenance tag (R25) before writing. `[verified YYYY-MM-DD]` requires that
   this session saw the proof: paste the command, log line, or `path:line` into the entry.
   Anything short of that is `[inferred]`, and an `[inferred]` lesson never reaches
   `ESSENTIALS.md`.

5. **Write** the new entry:
   - Use the file's existing format (numbered entries, dated headings, or free-form
     bullets - match what is there).
   - Every code claim carries a `path:line` you verified from disk this session (R6).
     Never fabricate a citation.
   - ASCII prose (R10): no em-dash, en-dash, or unicode ellipsis. Use `-` and `...`.
     Fenced blocks are exempt and must not be rewritten.
   - No personal absolute paths in the entry body unless describing local layout.
   - Cross-link from the entry back to the journal that discovered it (see step 7).

6. **Health-check the destination file** (AGENTS.md section 5):
   - If the file passed ~500 lines or mixes 3+ unrelated concerns, split the secondary
     concern into a new `knowledge/<concern>.md`, leave a one-line cross-reference in the
     original, register the new file in `INDEX.md`.
   - If the same topic now appears in 2+ entries after your append, merge into one
     canonical entry and cross-link the rest.
   - If your addition covers a previously-known issue that has been fixed for more than
     two releases, prune the old entry (or move it to a `*-archive.md`).

7. **Annotate the source journal** (if the lesson came from one): add
   `[promoted -> <knowledge file>:<section>]` on the lesson line, and add a bullet under
   the journal's "Promoted to knowledge" section.

8. **INDEX.md update**: if you added a new knowledge file or a new project got a
   knowledge subtree for the first time, add a row to the appropriate table in
   `HUB_ROOT/INDEX.md` with its FIRES WHEN condition.

9. **Commit and push the hub** (R15), echoing the commit message in the response.

## Validation

- The knowledge file now contains the lesson, phrased as a durable fact (not a
  narrative).
- The lesson's source journal (if any) shows the `[promoted -> ...]` tag on that lesson
  and a "Promoted to knowledge" bullet.
- No duplicate exists in the destination (R4).
- No code citation is invented (R6).
- The new entry carries exactly one provenance tag, and a `[verified]` tag is backed by
  evidence captured in the entry itself.
- File is still under ~500 lines or has been split.

## Guardrails

- One file per concern (R4). Never fork a topic.
- One-way promotion: journal -> knowledge. Never copy knowledge back into a journal
  (AGENTS.md section 11).
- Ephemeral / task-specific facts do not belong in knowledge. If a "lesson" is really
  "for this ticket only", leave it in the journal.
- If unsure which file a lesson belongs in, ask the user rather than guessing
  (R2 > token savings).

## Example prompts

- "promote this lesson: the Kafka listener requires `AUTOCOMMIT=false` to survive <vendor> retries"
- "add to <project-b> known-issues: TICKET-1031 rounding drift comes from the <vendor> XML parser truncating past 2dp"
- "record this fix in conventions"
- "capture this convention across the repo"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). Code-repo commits forbidden; the hub auto-commits and pushes (R15).
