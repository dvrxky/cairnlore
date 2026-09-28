# 003. Evidence-backed knowledge corrections do not stop for confirmation

Status: accepted
Date: 2026-09-28

## Context

R25 and `promote-lesson-to-knowledge` step 3 tell a session that disproves a knowledge
entry to replace it in place. Section 6 requires a fresh confirmation before overwriting
existing content, and lane 0 of section 13.1 routes every overwrite to SAFETY, overriding
all other lanes. Read together, every correction stops the task and waits. ADR 002 makes
reviews correct knowledge routinely, so a review that disproves five entries would stop
five times, and a loop that stops that often gets skipped.

## Options considered

### A. Confirm every correction
Trade-off: the user sees each change before it lands, but correction becomes the
expensive path, so wrong entries stay.

### B. Correct without confirmation, and name every correction in the same response (chosen)
Trade-off: a wrong correction lands before the user sees it, but it is named in that
response, git holds the old text, and reverting one entry costs less than the stop.

### C. Batch corrections for confirmation at the end of the task
Trade-off: one stop instead of many, but later steps in the same task read knowledge
already known to be wrong, and a long task's batch goes stale.

## Decision

We will exempt from section 6's confirmation any correction to a single hub knowledge
entry that the session disproved with evidence, when the same response names the
correction. An entry that states a rule, spec, or acceptance criterion is never corrected
this way; its mismatch is surfaced instead (R7). Deleting a whole knowledge file still
needs confirmation.

## Consequences

Easier: knowledge converges on the code at the pace sessions read it.

Harder: the user's check moves from before the change to after it, so the named
correction must be specific enough to veto: file and entry, never "updated knowledge".

Locked in: section 6, lane 0, and R8 each carry the exception or the line it requires.
Reversing means restoring confirmation and accepting that corrections become rare.
