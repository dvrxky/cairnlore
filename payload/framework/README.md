# ai-self-organizing-framework

> This is the **shippable copy** of the framework, kept inside every hub at
> `HUB_ROOT/framework/`. The **active engine** for a hub is at `HUB_ROOT/AGENTS.md` and
> `HUB_ROOT/INDEX.md` (kept in sync with the files here). To bootstrap a new hub, copy
> this directory. There is no external framework repo.

A tiny, domain-agnostic framework that gives an AI coding agent a **self-organizing,
self-updating memory** for any project, in ONE centralized shared hub repo. It distills
three ideas into five files:

1. **Progressive disclosure** - the agent reads two small files at startup and loads
   deeper knowledge only when a request needs it.
2. **A self-maintenance loop** - the moment the agent learns something (a fact, a fix,
   a convention), it records it in the right knowledge file in the same turn, so the
   knowledge base grows itself and no future session repeats a dead end.
3. **A source-of-truth chain** - every answer comes from a defined order (index ->
   knowledge file -> real code at `file:line` -> external doc), and every code claim is
   cited from disk, never from memory.

It is deliberately small. No agent-specific skill format, no scripts, no ceremony -
just markdown any agent can read.

The framework is centralized in one shared hub repo. Every project the agent works on
gets a subtree under `HUB_ROOT/knowledge/projects/<project>/` and (if it has many tasks)
`HUB_ROOT/journal/projects/<project>/`.

## The whole framework

```
framework/                        # (this dir; shippable copy inside HUB_ROOT/)
+-- AGENTS.md                     # THE ENGINE - rules + the loop + git model + how to build/contribute. Read first, always.
+-- INDEX.md                      # Source-of-truth map - knowledge + skills, triggers, answering order.
+-- knowledge/                    # FACTS to recall (self-maintained)
|   +-- config.md                 # build, run, env, versions
|   +-- conventions.md            # patterns, domain rules, mappings
|   +-- known-issues.md           # errors + fixes + agent lessons (checked first on failure)
+-- skills/                       # STEPS to execute (repeatable workflows)
|   +-- _template/SKILL.md        # author new skills from this
|   +-- start-task/SKILL.md       # open a per-task journal at the start of a task
+-- journal/                      # RAW per-task records (goal, clarifications, decisions, lessons)
|   +-- _template.md              # a new journal per task, created by start-task
+-- README.md                     # this file
+-- USAGE.md                      # step-by-step guide for hooking a hub up and running a task
```

Two files are read at startup (`AGENTS.md` + `INDEX.md`), plus any task journal still in
progress. Everything under `knowledge/` and `skills/` loads on demand when a request matches
its triggers in `INDEX.md`.

## Agent-agnostic: one entry file, no vendor files

The framework ships exactly one instruction file: `AGENTS.md`. It is read natively by most
coding agents (Codex, Amp, OpenCode, Cursor, and others). There are **no** Copilot-, Claude-,
or Gemini-specific files. If your agent reads a different filename, you **symlink** it - you
never copy the content into a second file:

```bash
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md GEMINI.md
mkdir -p .github && ln -s ../AGENTS.md .github/copilot-instructions.md
```

One source of truth, hooked into any agent by a link. This keeps the single-file guarantee
(AGENTS.md R4) intact.

## Three artefacts: knowledge, skills, journals

- **Knowledge** (`knowledge/*.md`) = facts the agent recalls: config, conventions, known
  issues. Distilled, durable, deduplicated. Split into cross-project files at the hub root
  and per-project files under `knowledge/projects/<project>/`. Grows itself through the
  self-organizing loop.
- **Skills** (`skills/<verb-noun>/SKILL.md`) = a named, repeatable workflow with triggers
  and numbered steps that the agent runs on request. Folder-per-skill layout matches
  opencode's native discovery. Build one from `skills/_template/SKILL.md` once a workflow
  has been done twice. See AGENTS.md section 8.
- **Journals** (`journal/*.md`) = the raw, chronological record of ONE task: goal,
  clarifications and their answers, decisions and their reasons, and lessons found while
  implementing. Opened automatically at the start of a task by the `start-task` skill, and
  appended to in the same turn you learn something (AGENTS.md R14, section 11). At close,
  durable lessons are promoted into `knowledge/*`; the journal keeps the full narrative.

Knowledge and skills load on demand by trigger; a journal loads when its task is in progress.
All three live in the hub and are committed by you (or by the agent if you have opted in
for that session), never inside a project code repo.

## How the self-organizing loop works

Whenever the agent discovers anything new during a session:

```
STOP  ->  CLASSIFY  ->  RECORD in the matching knowledge/*.md  ->  CITE in INDEX.md  ->  RESUME
```

- An **error and its fix** -> `knowledge/projects/<project>/known-issues.md` (or the
  cross-project `knowledge/known-issues.md`)
- A **pattern, rule, or domain fact** -> `conventions.md`
- A **build/env/version fact** -> `config.md`
- A **new component or project** -> the component map in `INDEX.md`

On any unexpected failure the agent checks `known-issues.md` **before** retrying, so past
debugging is reused instead of repeated. Files that grow past ~500 lines or mix concerns
get split; duplicates get merged; stale issues get pruned. See `AGENTS.md` sections 3-5.

## The source-of-truth chain

Any question about a project is answered in this order (stop when answered):

1. `INDEX.md` - orientation + component map
2. the matching per-project `knowledge/projects/<project>/*.md`, then the cross-project
   `knowledge/*.md`
3. the real source at a verified `path/to/file:line` (read from the project's main clone
   in the current session)
4. the external fallback the INDEX names (design doc, wiki, ADR)

Every code claim carries a `path:line` the agent verified from disk this session.

## Git model (the agent never commits inside code repos)

This framework updates knowledge files on disk **immediately**. It does **not** commit,
build, or deploy in any project code repo. That work stays with you.

- The agent never runs `git commit` inside a project code repo. Ever.
- The agent never runs build / deploy / CI / release commands.
- Destructive actions (delete, revert, overwrite) need a fresh in-session confirmation.
- Every task that leaves changes ends by printing a ready-to-use commit message in a
  single fenced block (matching your repo's prefix convention).

**Hub commits are opt-in.** If you tell the agent (in a session or via a persistent
rule) to commit and push hub updates, the agent may do so ONLY inside the hub worktree
on the hub branch, and still prints the commit message. Code-repo commits remain
forbidden. See `AGENTS.md` section 6.

## Where it lives: the central hub (worktree model)

The framework and every fact/skill it records live in ONE shared repo - the **central
hub** - checked out as an ordinary worktree. All names/paths are parameters in the
`Operating model` block of `INDEX.md` (`HUB_REPO`, `HUB_WORKTREE`, `HUB_ROOT`,
`HUB_BRANCH`).

- **Every knowledge/skill/journal write lands in the hub**, no matter which project code
  repo you are coding in: the files physically live in the hub worktree, so writing
  there = writing to the hub branch (AGENTS.md R13). No branch switching in the code
  repo, no framework artefacts in code branches.
- **No code-branch sync anymore.** The hub does not merge in code. When the agent needs
  a `path:line` citation, it reads the code directly from that project's main clone
  (`R6`). If a main clone is not checked out, the agent asks you to check it out.

## Adopt it in a hub

See `USAGE.md` sections 2-3 for the concrete steps: create the hub worktree, install the
framework, fill the `Operating model` block, hook the agent, then bootstrap the first
project.

## Building skills and contributing back

- **Add a skill:** ask the agent to "add a skill for X". It searches for an existing one
  (never duplicates), scaffolds `skills/<verb-noun>/SKILL.md` from
  `skills/_template/SKILL.md`, fills the steps, and registers it in `INDEX.md`. AGENTS.md
  section 8.
- **Add or change a rule:** engine rules live in `AGENTS.md` as `R<n>`. The agent gives
  a new rule the next id, keeps it to one sentence, and bumps the version header. Engine
  changes affect every hub using the framework, so they stay small and conservative.
  AGENTS.md section 9.
- **Two homes, always classified:** project-specific facts/workflows go in
  `knowledge/projects/<project>/` or `skills/`; changes to the engine itself go in the
  framework source repo's `AGENTS.md`. One file per concern, never a fork of a topic
  (R4).
- **You commit code changes, always.** Hub commits are opt-in (section 6).

## What you customize

- The trigger-keyword rows, skills table, and component map in `INDEX.md`.
- The knowledge files - they fill themselves as the agent works, but you can seed them.
- Add new `knowledge/<concern>.md` files for concerns that outgrow the defaults, and new
  `skills/<verb-noun>/SKILL.md` workflows, registering each in `INDEX.md`.

## What you do NOT need to touch

`AGENTS.md` is the stable engine. It is domain-agnostic - change it only if you want to
alter the rules or the loop themselves.
