# 001. Split Cairnlore into a public engine repo and a private hub repo

Status: accepted
Date: 2026-09-19

## Context

The framework has to run on machines with different publishing rights. Some can push
anywhere. Others can pull from the public internet but must never push to a private repo,
and the knowledge they hold must stay where it is.

Earlier the engine and the knowledge lived in one repository. That made every sync
question hard: vendoring the engine into a hub required clone-to-temp plus rsync because
two git repos cannot overlap on the same files, and any push path from a restricted
machine was a standing leak risk.

The ACE results (ICLR 2026) also require the knowledge layer to evolve by incremental
delta rather than wholesale rewrite, which is easier to reason about when knowledge is not
entangled with engine files that legitimately do get rewritten in place.

## Options considered

### A. One repository holding engine and knowledge
Trade-off: simplest to maintain, but the engine can never be published, and a restricted
machine would need credentials for a private repo.

### B. Engine vendored into each knowledge repo
Trade-off: knowledge and engine version together, but syncing needs rsync machinery
because nested git repos are not supported, and engine edits can happen in the wrong copy
and silently fork.

### C. Public engine repo, private hub repos (chosen)
Trade-off: more repos to know about, but each has exactly one owner, one direction of
flow, and no credentials needed on a restricted machine.

### D. Git submodules
Trade-off: the git-native answer, but it records a private repo URL inside another repo,
breaks for anyone without access to that URL, and adds detached-HEAD failure modes for no
benefit here.

## Decision

We will split into two kinds of repository:

- `cairnlore` (public): the engine only. Rules, skills, templates, installer. No knowledge
  and nothing specific to any one setting.
- one or more hubs (private): knowledge, journals, and playbook. Each hub is independent
  and never merges with another.

The engine flows DOWN into every machine by `git clone` plus `git pull`, installed as a
sibling directory and symlinked into place. Knowledge never flows UP. On any machine
without push rights the engine remote is disabled with
`git remote set-url --push origin DISABLED`, so a push fails at the git layer rather than
relying on discipline.

Engine improvements discovered on a pull-only machine are exported as scrubbed text via
the `capture-upstream` skill rather than committed locally.

## Consequences

Easier: updating the engine everywhere is one `git pull`. The engine is publishable and
reviewable in isolation. There is no code path by which private knowledge reaches a public
repo, so the leak question is answered by topology rather than by care.

Harder: more repos than one. Someone cloning a hub gets knowledge but no engine and must
clone the public engine separately. Engine fixes noticed on a pull-only machine take a
round trip through a publishing machine instead of being committed on the spot.

Locked in: the engine must stay free of anything setting-specific, permanently, because it
is public. Reversing this would mean either making the engine private, which costs the
ability to share it, or auditing its whole history for leaked identifiers.
