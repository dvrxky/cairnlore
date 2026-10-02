# 004. Local work stays in force until upstream ships it

Status: accepted
Date: 2026-10-02

## Context

Machines without push rights export engine improvements as scrubbed paste blocks (ADR 001).
The global rules on those machines give the engine precedence on every conflict, so a
captured rule stays dead until the publishing machine ships it. On one machine, the rules
that let reviews correct knowledge sat inert for a day this way. The installer replaces
local copies of global rules and skills and only warns. No file tracks which captured
changes are still unshipped, so whether one has shipped is found by reading task journals.

## Options considered

### A. The engine always wins; a local change waits for upstream
Trade-off: one source of truth, but every capture is dead for a round trip, and the machine
that found the problem keeps hitting it until the change ships.

### B. Local copies win permanently
Trade-off: no waiting, but every machine forks the engine and drifts.

### C. Local wins until shipped, then retires (chosen)
Trade-off: a pending register and a shipped check per capture, but the local change works at
once, and the fork ends the moment the engine holds it.

## Decision

We will treat each capture as a pending entry in the hub: a file in `upstream/` plus a row
in the hub INDEX with a shipped check. A pending entry outranks the engine text it changes
for every session on that hub. Each session runs the checks at start and retires an entry
the moment its check passes. Syncs never overwrite unshipped local work.

## Consequences

Easier: a capture takes effect on the machine that found it, at once. The register shows
what is still unshipped.

Harder: the engine is no longer the only rule source on a pull-only machine. A shipped check
that is too loose retires an entry early, and one that is too strict keeps it forever.
Upstream may ship a different version; the entry then stays in force and the difference is
surfaced, never silently resolved.

Locked in: the precedence carve-out in the global rules. Reversing means deleting the
register and R28.
