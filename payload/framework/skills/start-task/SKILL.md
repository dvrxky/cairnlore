---
name: start-task
description: Open (or resume) a per-task journal in the hub at the start of a non-trivial task. Captures the goal, clarifying questions and their answers, decisions, and in-flight lessons as work happens. Use when the user says "start a task", "new task", "let's implement", "I'm working on", "begin work on", or "kick off". For closing a task, use the `close-task` skill.
---

# Skill: Start a task (open a task journal)

> Opens a per-task journal in the hub that captures the goal, clarifications and their
> answers, decisions, and lessons as the work happens. Same mechanics as the rest of
> the framework: hub-only, parameterized, only commits inside the hub if the user has
> opted in for the session (AGENTS.md R2, R13, R14, sections 6 / 10 / 11).
>
> For closing a task (promote lessons, mark Done): see `skills/close-task/SKILL.md`.

- **triggers:** start a task, new task, let's implement, I'm working on, begin work on, kick off
- **preconditions:**
  - The `Operating model` block in `INDEX.md` is filled (`HUB_REPO`, `HUB_WORKTREE`, `HUB_ROOT`, `HUB_BRANCH`).
  - The task is non-trivial (multi-step or real implementation). For a one-off question, skip journaling.

## Steps

1. Resolve `HUB_WORKTREE` / `HUB_ROOT` from `INDEX.md`. Journals live at
   `<HUB_WORKTREE>/<HUB_ROOT>/journal/` (cross-project) or
   `<HUB_WORKTREE>/<HUB_ROOT>/journal/projects/<project>/` (per-project, if that project
   has enough traffic).
2. Check the journal dir for an existing journal for this task with status not `Done`.
   If found, **resume it** - never create a second (R4).
3. Derive a slug from the task (lowercase, hyphenated, <= 40 chars). Create
   `<YYYY-MM-DD>_<slug>.md` from `journal/_template.md`.
4. Fill: goal and scope from the request; project (if any); code-repo path; link if
   given; status `In progress`.
5. List the clarifying questions you need before implementing and ask the user (R2).
   Record each answer under Clarifications in the same turn.
6. Proceed with the task. As you work, append to the journal in the SAME turn you learn:
   - a clarification and its answer
   - a decision and its reason
   - an in-flight lesson or gotcha
   When a lesson is durable, run `promote-lesson-to-knowledge` in the same turn.
7. Handle commits per AGENTS.md section 6:
   - Code changes in the project repo: NEVER commit; surface a commit message.
   - Hub changes: commit only if the user has opted in this session; otherwise surface
     the hub commit message.

When the work is done, run the `close-task` skill.

## Validation

- A single journal exists for this task, status `In progress`, with the goal and any
  answered clarifications recorded.

## Guardrails

- One journal per task (R4). Resume, never duplicate.
- Journals live only in the hub (R13). Never inside a project code repo.
- Code-repo commits are forbidden (section 6). The hub auto-commits and pushes (R15).

## Example prompts

- "start a task: add pagination to the results endpoint"
- "I'm working on TICKET-1234"
- "let's implement the retry logic"
- "kick off the killswitch cleanup"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). Never commit code-repo changes; the hub auto-commits and pushes (R15).
