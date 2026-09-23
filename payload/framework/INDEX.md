# INDEX.md - Source of Truth Map

> The canonical map of a hub's knowledge. The agent reads this at session start
> (with `AGENTS.md`) and loads a knowledge file only when a request matches its
> triggers. Humans read it to find the one true place an answer lives.
>
> Fill the `<...>` placeholders when adopting. Keep it short - it is a map, not the
> content.
>
> Version: v2.0.0

---

## Operating model (read once per session - see AGENTS.md section 10)

The framework is centralized in a single shared hub repo. Every project's knowledge,
skills, and journals live here, not in the project code repos. Fill these for this hub;
the agent resolves them at startup and writes all knowledge here (R13).

| Parameter | Value for this hub |
|---|---|
| `HUB_REPO` | `<hub-repo-name>` |
| `HUB_WORKTREE` | `<absolute path to the hub checkout>` |
| `HUB_ROOT` | `<hub-root-dir>` (relative to `HUB_WORKTREE`) |
| `HUB_BRANCH` | `<the long-lived branch this hub is on>` |

All `knowledge/*.md`, `skills/*/SKILL.md`, and `journal/*.md` paths below are relative
to `HUB_WORKTREE/HUB_ROOT`.

There is NO code-branch sync anymore. When a citation needs the code, the agent reads
the code directly from the relevant project's main clone (`R6`). If a main clone is
missing, the agent asks the user to check it out.

---

## Always loaded at session start

| File | Purpose |
|---|---|
| `AGENTS.md` | The engine: rules R1-R25 and the self-organizing loop |
| `INDEX.md` | THIS FILE - what exists and when to load it |
| `ESSENTIALS.md` | The always-loaded playbook: earned items with h/m counters, soft target 40 items (R19) |

Not auto-loaded, but read `OVERVIEW.md` (hub root) if you need the whole framework
explained on one page: layers, startup, folders, the four gates, and why each choice.

## Knowledge files (load on demand)

### Cross-project (hub root)

| File | Load when the request is about... | Trigger keywords |
|---|---|---|
| `knowledge/config.md` | shared build/env/version facts across <your-domain> | `<shared build, <your-domain> env, shared version>` |
| `knowledge/conventions.md` | shared conventions across <your-domain> | `<shared pattern, <your-domain> convention>` |
| `knowledge/known-issues.md` | errors/failures that hit multiple projects | `<shared error, cross-project fail>` |
| `<knowledge/...>` | `<...>` | `<...>` |

### Per project (`knowledge/projects/<project>/`)

| Project | Load when the request is about... | Trigger keywords |
|---|---|---|
| `<project>` | anything specific to that project | `<project name, its modules>` |

Rule: read only these tables at startup. Open a knowledge file the moment a request
matches its row. If already loaded this session, do not reload.

## Skills (repeatable workflows - load and run on demand)

> A skill is steps to execute, not facts to recall (AGENTS.md section 8). Each skill
> lives as `skills/<verb-noun>/SKILL.md` (folder + SKILL.md) so opencode's native
> discovery picks it up. `skills/_template/SKILL.md` is the authoring template and is
> never loaded as a workflow.

> **The user never names a skill.** The FIRES WHEN column is a condition the agent
> evaluates itself (AGENTS.md R21, R22, section 13). When it holds, run the skill in the
> same turn, unasked.

| Skill | What it does | FIRES WHEN (condition, evaluated by the agent) |
|---|---|---|
| `skills/write-spec/SKILL.md` | gate 1: turn a feature request into a durable spec after grilling requirements | a request changes observable behaviour, touches >2 files, implies an unwritten business rule, contains an unresolved "or", or forces a material assumption (section 13.2) |
| `skills/grill-me/SKILL.md` | interrogate a spec or plan branch by branch until every decision is resolved and every remaining assumption is named | gate 1 or gate 2 is closing, two assumptions were made in a row without confirmation, or a one-sentence request implies a week of work |
| `skills/write-adr/SKILL.md` | record ONE architectural decision immutably (context, options, decision, consequences) | a boundary/dependency/schema/contract changes, sync<->async moves, data ownership shifts, a new pattern appears, or you catch yourself writing "we could either X or Y" |
| `skills/reflect-and-curate/SKILL.md` | close the self-improvement loop: grade playbook items on execution feedback, apply deltas | a task ends, a surprise or repeated failure occurs, or a turn contradicts an ESSENTIALS item |
| `skills/audit-knowledge-health/SKILL.md` | measure which knowledge is load-bearing, orphaned, or unverified, and which playbook items have never helped | ESSENTIALS passes 40 items, a pointer is suspected broken, or the user asks whether the hub is healthy |
| `skills/capture-upstream/SKILL.md` | emit a scrubbed, paste-ready block describing an ENGINE improvement | you learn something that should change a rule/skill/workflow on a machine whose engine clone cannot push |
| `skills/start-task/SKILL.md` | begin a non-trivial task and open its journal | work will span more than one turn or three steps and no journal is open |
| `skills/close-task/SKILL.md` | close a journal, promote lessons, mark Done | the last plan step is done, or the user signals the work is finished in any wording |
| `skills/promote-lesson-to-knowledge/SKILL.md` | record a discovered fact/fix/convention in the correct knowledge file (R3 loop) | you learn a fact that would have saved time at the start, hit a non-obvious error cause, or find a constraint absent from `knowledge/` |
| `skills/bootstrap-project/SKILL.md` | seed a new project subtree in the hub the first time you work on it | you are about to write knowledge about a project that has no subtree under `knowledge/projects/` |
| `skills/verify-skill-registry/SKILL.md` | dedup-check before authoring a skill; audit the registry for drift | you are about to create a skill, or two skills appear to have overlapping conditions |
| `skills/adversarial-review/SKILL.md`
| `skills/avee-ring-bake/SKILL.md` | bake the Avee AQUA (#5be0ff) 40% volume-reactive polar ring hugging the Avee logo PIN (logo box 42x75 at 37,1021; pin center =58,1058; ring innerRadius 78 hugging the pin) over an Avee film slice (approved 12s sample) or the full 71-min Avee film, keeping the film's own original Avee sound, via nodejs-audio-visualizer; npm reads ONLY FLAT polar keys (polarX/polarY/polarInnerRadius/polarMaxBarLength/polarBarWidth at outVideo root), never a nested polar{}; npm SKIPS existing outVideo.path silently (rc=0 no-op) so ALWAYS bake to a brand-new unique literal and ffprobe ONLY that literal | "bake the Avee ring", "Avee ring sample", "Avee AQUA ring", "ring hugging the Avee logo pin", "shrink the Avee ring", "regenerate the Avee sample", "make the Avee ring hug the Avee logo" |
 | fresh-context, BLOCK-only review of a diff (operationalises R12) | a diff you wrote is about to be handed to a human |
| `<skills/verb-noun>` | `<the workflow to run>` | `<...>` |

## Task journals (per-task artefact - AGENTS.md section 11)

Per-task chronological records live at `HUB_ROOT/journal/<YYYY-MM-DD>_<task-slug>.md`.
Per-project journals may live at `HUB_ROOT/journal/projects/<project>/<YYYY-MM-DD>_<slug>.md`
if a project has enough traffic. They are created/resumed by the `start-task` skill and
hold goal, clarifications and answers, decisions, and in-flight lessons. At session
start, load any journal still `In progress` to restore its context. Durable lessons are
promoted one-way from a journal into the knowledge files.

---

## Answering order (the source-of-truth chain)

When asked anything about a project, answer in this order and stop as soon as answered:

1. **INDEX.md** (this file) - orientation and the component map below.
2. The matching **`knowledge/*.md`** file (per-project first, then cross-project).
3. The real **source code** at a verified `path/to/file:line` reference (read it this
   session from the project's main clone).
4. The **external fallback** named in the component map (design doc, wiki page, ADR) -
   only for product/history/ops context that source code cannot answer.

Every code claim carries a `path:line` you verified from disk this session (AGENTS.md R6).

---

## Component map

> The high-level index of what this hub covers. One row per project (or major shared
> component). This is where a new project gets registered (AGENTS.md section 4). Keep
> each entry to purpose + code-repo path + entry points + a fallback link.

| Project / component | What it is | Code repo (main clone) | Knowledge here | Deeper doc / external fallback |
|---|---|---|---|---|
| `<project>` | `<one line>` | `<path to main clone>` | `knowledge/projects/<project>/` | `<wiki / ADR>` |

### `<project-name>`

- **Purpose:** `<one line>`
- **Code repo (main clone):** `<absolute path>`
- **Inputs / outputs:** `<upstream and downstream wiring - queues, HTTP, DB, files>`
- **Key entry points:** (cite from the code repo, not this hub)
  - `<path/to/file:line>` - `<what happens here>`
- **Gotchas:** `<non-obvious behavior a newcomer would trip on>`
- **Fallback docs:** `<canonical external page for product/history/ops context>`

---

## Citation and doc conventions

- **Citations:** `path/to/file:line`, verified from disk this session (read from the
  project's main clone). Never invented.
- **Typography:** ASCII only (AGENTS.md R10). No em/en dashes, no unicode ellipsis.
- **No personal absolute paths** in anything meant to be shared or published. Use
  repo-relative paths inside citations. Absolute paths are OK in this INDEX's
  Operating model + Component map blocks (they describe local layout).
- **Escape angle-bracket generics in prose** with backticks (`` `Set<Long>` ``,
  `` `Map<String, Object>` ``) so downstream markdown-to-HTML publishers do not choke.
- **If you publish this INDEX or a knowledge file to a wiki**, that MD file stays the
  source of truth. The published page is a mirror: mark it "do not edit here" and
  re-publish from the MD, never the reverse.
