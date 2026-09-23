---
name: adversarial-review
description: Fresh-context, adversarial review of a diff or PR where the reviewer is NOT the implementer. Use when the user asks to "review this diff/PR", "adversarial review", "critique my change", "find defects before I merge", or when a task wants an independent check before it is declared done. Reports only BLOCK-level findings; nits are out of scope.
---

# Skill: Adversarial Review

> The implementer does not grade its own work. This skill runs a review from a fresh
> perspective: given the diff plus whatever spec / ticket / acceptance criteria exist,
> find real defects only. It operationalises AGENTS.md R12 (reviews report only what
> matters) and R6 (cite from disk).

- **triggers:** "review this diff", "review the PR", "adversarial review", "critique my change", "find defects before merge", "independent review"
- **preconditions:** a diff or PR to review; any spec / ticket / acceptance criteria the change claims to satisfy

## Mindset

You are the reviewer, not the author. You are rewarded for finding real gaps and
penalised for noise. A review reporting zero findings is a valid outcome; a review that
fabricates findings to look thorough is a defect.

## Steps

1. Gather context in order: the requirement (ticket / spec / acceptance criteria), then
   the diff. For a GitHub PR: `gh pr diff <N> --repo <owner>/<repo>` and
   `gh pr view <N> --json title,body`.
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
   return them directly to the user. Do NOT auto-apply fixes unless asked.

## What does NOT count as a finding

- Naming preferences ("I would call it X").
- Features beyond the stated scope.
- Rewrites of working code for taste.
- Anything a linter / formatter / type-checker already enforces.

## Validation

- Every reported finding is BLOCK or REQUEST_CHANGES, cited at `path:line`, verified from
  disk this session.
- Zero nits, zero praise. If nothing critical is found, say so in one line (R12).

## Guardrails

- **AGENTS.md R12:** report only what matters; nits are out of scope.
- **AGENTS.md R6:** cite from disk, never from the diff hunk alone.
- **AGENTS.md R13 / section 6:** review is read-only on the code repo; never commit or
  merge; the artefact is the review, not a code change.

## Example prompts

- "adversarial review of PR #236 before I merge"
- "review this diff, block-level only"
- "independent check on my change against the ticket"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
