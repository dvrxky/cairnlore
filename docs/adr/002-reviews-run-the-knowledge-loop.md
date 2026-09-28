# 002. Reviews run the knowledge loop, scoped to the branch the knowledge tracks

Status: accepted
Date: 2026-09-28

## Context

A review reads code more closely than almost any other task: every finding must be
verified at `path:line` (R6). Yet the review path wrote nothing back.
`skills/adversarial-review` loaded the ticket and the diff but never the hub, sent
findings only to chat or the journal, and named the review itself as the artefact.
Section 13.1 placed reviews in lane 1, defined as "no change to disk", and R12 shaped the
report without mentioning R3. In one hub, the history's only review-related commit was a
one-line playbook counter bump.

Recording what a review sees has a trap. A PR's changes are not yet true anywhere.
Knowledge that describes one branch, for example specs of `master` while PRs target
`develop`, would absorb unmerged and possibly abandoned code as fact.

## Options considered

### A. Reviews stay report-only
Trade-off: knowledge cannot be polluted, but every review re-derives the same facts,
pre-existing defects found in passing are lost, and entries the code contradicts survive
every review that could have caught them.

### B. Record everything the review sees, including the PR's own changes
Trade-off: maximum capture, but unmerged code is stated as current truth, and abandoned
PRs need a cleanup that nothing performs.

### C. Record only what is true on the branch the knowledge tracks (chosen)
Trade-off: the PR's own facts arrive later, through the next refresh after merge, but
knowledge never describes code that is not on the branch it claims to describe.

## Decision

We will make every review run the R3 loop. It loads the component's knowledge before
reviewing, records what it establishes about the tracked branch that knowledge lacks,
corrects entries that code on that branch disproves, and names each in one trailing
`Knowledge:` line. The tracked branch is the one the project's knowledge states; when
none is stated, it is the PR's base branch, and the review records that in the project's
`config.md`. What the PR adds or breaks stays in the review reply until
`git merge-base --is-ancestor` shows it on the tracked branch. A mismatch with an entry
that states a business rule, spec, or acceptance criterion is a finding, never a
correction (R7).

## Consequences

Easier: knowledge compounds from the tasks that read code most closely, and a stale entry
is caught by the next review that touches its component.

Harder: a review is no longer read-only. It writes to the hub and pushes (R15), and the
reviewer must know which branch the knowledge tracks. Report noise is bounded to one line,
omitted when nothing was written.

Locked in: R12 governs the report only. Reversing this means removing step 6 from the
review skill and restoring lane 1's "no change to disk".
