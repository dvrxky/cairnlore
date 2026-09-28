---
name: adversarial-review
description: Fresh-context, adversarial review of a diff or PR where the reviewer is NOT the implementer. Use when the user asks to "review this diff/PR", "adversarial review", "critique my change", "find defects before I merge", or when a task wants an independent check before it is declared done. Reports only BLOCK-level findings; nits are out of scope. Also records what the review learns about the code into the hub's knowledge and corrects entries the code disproves.
---

# Skill: Adversarial Review

> The implementer does not grade its own work. This skill runs a review from a fresh
> perspective: given the diff plus whatever spec / ticket / acceptance criteria exist,
> find real defects only. It operationalises AGENTS.md R12 (reviews report only what
> matters), R6 (cite from disk), and R3 (what a review learns is recorded).

- **triggers:** "review this diff", "review the PR", "adversarial review", "critique my change", "find defects before merge", "independent review"
- **preconditions:** a diff or PR to review; any spec / ticket / acceptance criteria the change claims to satisfy; the INDEX row for the component under review

## Mindset

You are the reviewer, not the author. You are rewarded for finding real gaps and
penalised for noise. A review reporting zero findings is a valid outcome; a review that
fabricates findings to look thorough is a defect.

## Steps

1. Gather context in order: the requirement (ticket / spec / acceptance criteria), then
   the component's knowledge (its INDEX row, then the knowledge file that row names, R1),
   then the diff. For a GitHub PR: `gh pr diff <N> --repo <owner>/<repo>` and
   `gh pr view <N> --json title,body`. Note the branch the knowledge tracks: the one the
   project's knowledge states, else the PR's base branch.
2. Verify each code claim against disk (R6): read the changed files at `path:line`, do
   not trust the diff's surrounding context alone.
3. Classify every candidate finding by severity, report only the top two tiers:
   - **BLOCK** - correctness defect, security defect (secret/PII/credential in source,
     logs, or fixtures), data loss, broken contract, race, resource leak, a MUST
     requirement with no implementation OR no test, an edge case the diff demonstrably
     mishandles (null / empty / boundary / concurrent / idempotency).
   - **REQUEST_CHANGES** - a significant concern that is not strictly blocking.
   - **NIT** - style, naming preference, formatting: DO NOT report (the linter/formatter
     owns these; AGENTS.md R12).
4. For each reported finding give: severity, `path:line`, what is wrong, and why it
   matters. No praise, no restating what the diff does, no "consider..." suggestions.
5. If a task journal is open, append the findings under a "Review" note (R14). Otherwise
   return them directly to the user. Do NOT auto-apply code fixes unless asked.
6. Run the knowledge loop (R3) before sending the report. It writes only what is true on
   the tracked branch. What the PR adds or breaks is not true there yet: it stays in the
   reply until `git merge-base --is-ancestor <sha> origin/<tracked>` shows it merged.
   - Record, via `promote-lesson-to-knowledge`, what the review established that
     knowledge lacks: an invariant or contract the code relies on, a config or
     environment constraint, a pre-existing defect found in passing, and the tracked
     branch itself when the project's `config.md` does not name it.
   - Correct an entry the tracked branch disproves: replace it in place with the new
     truth and its tag (R25; section 6 exempts this from confirmation). An entry that
     states a business rule, spec, or acceptance criterion is never rewritten to match
     the code; the mismatch is a finding (R7).
   - Refine each file written: run the section 5 checks (split, merge, prune).
   - After the findings, add one line,
     `Knowledge: +N recorded, ~M corrected -> <file>:<entry>, ...`, naming each
     corrected entry so it can be vetoed, then commit and push the hub (R15). Omit the
     line when nothing was written. A review that established nothing new writes nothing.

## What does NOT count as a finding

- Naming preferences ("I would call it X").
- Features beyond the stated scope.
- Rewrites of working code for taste.
- Anything a linter / formatter / type-checker already enforces.

## Validation

- Every reported finding is BLOCK or REQUEST_CHANGES, cited at `path:line`, verified from
  disk this session.
- Zero nits, zero praise. If nothing critical is found, say so in one line (R12).
- The knowledge loop ran: what the review established about the tracked branch is
  recorded, every entry it disproved is corrected, and the `Knowledge:` line names each
  one. Nothing from the PR's unmerged changes was written as current truth.

## Guardrails

- **AGENTS.md R12:** report only what matters; nits are out of scope.
- **AGENTS.md R6:** cite from disk, never from the diff hunk alone.
- **AGENTS.md R13 / section 6:** review is read-only on the code repo; never commit or
  merge there. The hub is the only place a review writes (R3, R15).

## Example prompts

- "adversarial review of PR #236 before I merge"
- "review this diff, block-level only"
- "independent check on my change against the ticket"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
