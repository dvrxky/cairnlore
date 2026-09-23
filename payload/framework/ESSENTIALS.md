# ESSENTIALS.md - the always-loaded playbook

> Read every session, unconditionally (AGENTS.md R19). Evolves by DELTA only (R23):
> add, edit, or demote single items. Never rewrite this file wholesale, never merge two
> items into a vaguer one.
>
> Format: `[id] (h:helped m:misled) rule -> pointer to detail`
> Soft target 40 items. Past it, demote the lowest value ones; the detail already lives
> in `knowledge/`. An item with `m` >= 2 gets deleted or rewritten, never kept.

## Acting

- `[E-001] (h:0 m:0)` Verify against disk before claiming anything: branch, file contents, uncommitted state. Never trust a prior summary, including my own -> `AGENTS.md` R6
- `[E-002] (h:0 m:0)` Every code claim carries a `path:line` read this session -> `AGENTS.md` R6
- `[E-003] (h:0 m:0)` Spec before plan, plan before code -> `AGENTS.md` section 12
- `[E-004] (h:0 m:0)` Triage every request into a lane before acting; never wait for a trigger phrase -> `AGENTS.md` section 13.1
- `[E-005] (h:0 m:0)` Trip-wires fire skills unasked; an unfired trip-wire is an incomplete turn -> `AGENTS.md` section 13.2
- `[E-006] (h:0 m:0)` Three failed attempts at the same thing means STOP and escalate -> `AGENTS.md` R16
- `[E-007] (h:0 m:0)` Disagree when evidence contradicts the request -> `AGENTS.md` R17

## Writing

- `[E-008] (h:0 m:0)` Never commit in a project code repo; the hub always commits and pushes -> `AGENTS.md` R15
- `[E-009] (h:0 m:0)` ASCII only: no em/en dashes, no unicode ellipsis -> `AGENTS.md` R10
- `[E-010] (h:0 m:0)` Comments explain WHY, never WHAT; default to zero -> `AGENTS.md` R11
- `[E-011] (h:0 m:0)` Process docs: present tense, no archaeology -> `AGENTS.md` R18
- `[E-012] (h:0 m:0)` Knowledge: delta updates only, never wholesale rewrite -> `AGENTS.md` R23
- `[E-017] (h:0 m:0)` Every knowledge entry ends with `[verified <date>]` or `[inferred]`; an inferred claim never justifies a change -> `AGENTS.md` R25

## Where things go

- `[E-013] (h:0 m:0)` Durable facts to `knowledge/`, decisions to `adr/`, requirements to `specs/`, disposable steps to the journal -> `AGENTS.md` section 12
- `[E-014] (h:0 m:0)` Knowledge lives ONLY in the hub, never in a project code repo -> `AGENTS.md` R13
- `[E-015] (h:0 m:0)` End every task with generate, reflect, curate: update h/m counters, add what was missing, demote dead weight -> `AGENTS.md` R24
- `[E-018] (h:0 m:0)` Demote playbook items on measured evidence, never by merging them into something vaguer -> `skills/audit-knowledge-health/SKILL.md`

## Project facts

<!-- Add an item only after a fact has changed a decision on two separate tasks. -->

- `[E-016] (h:0 m:0)` `<seed your first load-bearing project fact here>` -> `knowledge/...`
