# AI Self-Organizing Framework - Usage Guide

How to hook the self-organizing framework into a hub and start implementing tasks in
its style: a centralized knowledge base that records its own learnings, journals every
task, and never commits inside a project code repo.

Framework source: this hub's `framework/` subdir (canonical shippable copy; the active
engine for this hub is `HUB_ROOT/AGENTS.md`, in sync with `framework/AGENTS.md`).
This guide is a workflow runbook (personal, not published). Any change to the workflow
lands in THIS file first, then gets executed.

---

## 0. What you are setting up (30-second model)

- The framework and every fact it learns live in ONE shared **hub** repo, checked out
  as an ordinary worktree. There are no `.ai/` folders inside project code repos, no
  `feature/docs` branches carrying knowledge.
- Three artefacts, all under the hub root:
  - **knowledge/** - distilled durable facts, split into cross-project files at the
    hub root and per-project files under `knowledge/projects/<project>/`.
  - **skills/** - repeatable workflows as `skills/<verb-noun>/SKILL.md` folders
    (opencode-discoverable).
  - **journal/** - one raw chronological record per task, cross-project at the hub
    root or per-project under `journal/projects/<project>/`.
- The agent reads `AGENTS.md` + `INDEX.md` at session start, loads the rest on demand,
  records what it learns in the same turn, and hands you commit messages. It never
  commits inside project code repos; it may commit inside the hub if you have opted in.

---

## 1. Prerequisites

- One hub repo. The default hub in this environment is `<hub-repo>`, worktree
  `<hub-repo>-worktrees/<hub-root>`, root dir `<hub-root>/`, branch
  `docs/risk-ai-self-organizing-knowledge-framework`.
- The project code repos are ordinary clones; the agent reads them for `path:line`
  citations but never writes framework artefacts to them.
- You use an agent that reads `AGENTS.md` (Codex, Amp, OpenCode, Cursor, ...). If yours
  reads a different filename, symlink `AGENTS.md` (see AGENTS.md section 0).
- The framework source lives in an existing hub's `framework/` subdir (for this hub:
  `~/git/<hub-repo>-worktrees/<hub-root>/<hub-root>/framework/`).
  Bootstrap a new hub by copying from any existing hub.

---

## 2. Hook the hub up (one time)

### 2.1 Create the hub worktree

```bash
cd ~/git/<hub-repo>
git worktree add ../<hub-repo>-worktrees/<hub-root> -b docs/risk-ai-self-organizing-knowledge-framework
```

### 2.2 Install the framework at `HUB_ROOT`

```bash
mkdir -p ../<hub-repo>-worktrees/<hub-root>/<hub-root>
cp -R <existing-hub>/framework/{AGENTS.md,INDEX.md,knowledge,skills,journal} \
      ../<hub-repo>-worktrees/<hub-root>/<hub-root>/
```

### 2.3 Fill the Operating model block

Edit `../<hub-repo>-worktrees/<hub-root>/<hub-root>/INDEX.md` and set the four
values near the top (`HUB_REPO`, `HUB_WORKTREE`, `HUB_ROOT`, `HUB_BRANCH`).

### 2.4 Hook your agent to the engine

```bash
cd ../<hub-repo>-worktrees/<hub-root>
# If the repo has NO root AGENTS.md, symlink the engine so the agent auto-reads it:
ln -s <hub-root>/AGENTS.md AGENTS.md
```

Skills are opencode-discoverable via symlinks under `~/.agents/skills/`:

```bash
ln -s ~/git/<hub-repo>-worktrees/<hub-root>/<hub-root>/skills/<slug> \
      ~/.agents/skills/<slug>
```

### 2.5 Commit the setup on the hub branch (you commit, unless opted in)

```bash
git add <hub-root> AGENTS.md
git status
# then commit yourself, e.g.:
git commit -m "[<hub-root>] init self-organizing framework hub"
git push -u origin HEAD
```

---

## 3. Bootstrap a project into the hub

The first time you touch a new project in a hub session:

> "Bootstrap project `<project-name>` (code at `<path>`)."

The agent:
- creates `knowledge/projects/<project>/` with headed `config.md`, `conventions.md`,
  `known-issues.md` templates,
- fills `config.md` from what it verifies in the project code repo (build tool,
  versions, how to run, entry points - each cited `path:line`),
- adds a component-map row for the project in `INDEX.md`,
- prints a commit message (or commits the hub, if opted in).

---

## 4. Implement a task in this style

### 4.1 Start the task (opens a journal automatically)

> "Start a task: <what you want to build>."   (or "I'm working on <issue>")

The agent (via the `start-task` skill):
- creates `journal/<YYYY-MM-DD>_<slug>.md` (or under `journal/projects/<project>/`),
- writes the goal and scope,
- asks the clarifying questions it needs BEFORE coding,
- records your answers in the journal.

Answer the questions. Everything you decide is captured.

### 4.2 Implement

Work normally. Code edits happen in the project's main clone on your feature branch as
usual; the knowledge and journal always land in the hub. As the agent goes, it appends
to the journal in the same turn it learns:

- each clarification and your answer,
- each decision and why,
- each gotcha or lesson.

When a lesson is durable, it also writes it into the right knowledge file
(`known-issues.md` / `conventions.md` / `config.md`, per-project or cross-project) and
notes the promotion in the journal.

The agent stages code changes and prints commit messages for the code repo. You commit
in the code repo. The hub is either handed to you the same way, or committed by the
agent if opted in.

### 4.3 Close the task

> "Close the task."

The agent fills the journal Outcome, promotes durable lessons into `knowledge/*`, sets
status `Done`, and prints the hub commit message.

---

## 5. Growing the framework

- **Add a skill (repeatable workflow):** "Add a skill for <X>." The agent scaffolds
  `skills/<verb-noun>/SKILL.md` from `skills/_template/SKILL.md`, fills the steps, and
  registers it in `INDEX.md`. Then symlink it into `~/.agents/skills/` if you want
  opencode to auto-discover it globally.
- **Add or change a rule:** "Add a rule: <X>." It appends the next `R<n>` in the
  framework's `AGENTS.md` (in this hub: `HUB_ROOT/framework/AGENTS.md`, kept in sync with
  the active `HUB_ROOT/AGENTS.md`)
  and bumps the version. Engine rules affect every hub, so they stay small.
- **One file per concern.** The agent finds the existing home and appends; it never
  forks a topic or duplicates a file.

---

## 6. The one rule you always own: committing inside project code repos

The agent updates files on disk and prints a ready-to-use commit message for any code
changes. You decide when it lands in the code repo. The agent never runs `git commit`
in a project code repo, never builds, never deploys.

The hub itself may be auto-committed by the agent if you have explicitly opted in for a
session. That is the only exception.

---

## 7. Cheat sheet

| You say | What happens |
|---|---|
| "Bootstrap project X (code at `<path>`)" | seeds `knowledge/projects/X/`, fills config, adds INDEX row |
| "Start a task: ..." | opens a journal, asks clarifying questions |
| "Close the task" | writes outcome, promotes lessons to knowledge |
| "Add a skill for ..." | new `skills/<slug>/SKILL.md`, registered in INDEX |
| "Add a rule: ..." | new `R<n>` in framework `AGENTS.md`, version bumped |
| any error | agent checks `known-issues.md` first, records the fix |

Files (all under `HUB_WORKTREE/HUB_ROOT`): `AGENTS.md` (engine), `INDEX.md` (map),
`knowledge/` (facts), `skills/` (workflows), `journal/` (per-task records).

---

