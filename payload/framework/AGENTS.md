# AGENTS.md - the Cairnlore engine

> This one file IS the engine. Every AI agent reads it first, every session.
> It is domain-agnostic: it says nothing about what you build, only how the agent
> keeps a project's knowledge organized, cited, and self-updating.
>
> Version: v4.2.0 (Cairnlore)

The framework is centralized in a single shared hub repo (see section 10).

---

## 0. How this file is loaded (agent-agnostic)

`AGENTS.md` is the single entry point. It is read natively by most coding agents
(Codex, Amp, OpenCode, Cursor, and others). No vendor-specific instruction file ships
with this framework. If your agent reads a different filename, do NOT copy this content
into a second file (that would violate R4) - **symlink** it instead:

```bash
ln -s AGENTS.md <whatever-your-agent-reads>   # e.g. CLAUDE.md, GEMINI.md, .github/copilot-instructions.md
```

One source of truth, hooked into any agent by a link, never a duplicate.

## 1. Session start (read three files, plus any open journal)

1. Read **this file** (`AGENTS.md`) - the rules and the loop.
2. Read **`INDEX.md`** - the map of every knowledge file and skill, and when to load each.
3. Read **`ESSENTIALS.md`** - the distilled playbook that applies to nearly every
   task (R19). This is the ONLY knowledge file loaded unconditionally.

Do NOT pre-load anything else. Load a `knowledge/*.md` file or a `skills/<slug>/SKILL.md`
only when the request matches the condition in that file's `INDEX.md` row (R22). This is
progressive disclosure: cheap startup, full depth on demand.

If a task journal is still In progress (section 11), load it too to restore that task's
goal, answered clarifications, and lessons before continuing.

---

## 2. The rules (always in force)

**R1 - Answer from the source of truth, in order.** For any question about this
project, follow the answering order in `INDEX.md`: INDEX first, then the matching
`knowledge/*.md` file, then the real source at a verified `path:line` reference,
then any external fallback the INDEX names. Never answer from generic knowledge when
a knowledge file exists for the topic.

**R2 - Never assume. Load first, then ask.** Before writing code, config, or any
project artifact, load the relevant knowledge file(s). If a fact is unclear (a name,
an enum, a rule, an edge case), ask the user one direct question rather than guessing.
Quality over token savings: always load the knowledge, whatever the cost.

**R3 - Self-maintain in the same turn.** The moment you discover a fact, fix a bug,
learn a convention, or find a non-obvious tool behavior, record it in the correct
knowledge file **immediately, before moving on** - not as a follow-up. Recording is
part of the fix, not a separate step. See section 3 for the loop.

**R4 - One file per concern. Never duplicate.** Always find and append to the
existing knowledge file. Never create a second file for a topic that already has one.
Split only when section 5 (reorganization) triggers.

**R5 - On any unexpected failure, check `known-issues.md` FIRST.** Do not retry with
variations. Search known-issues for the error, tool, or command. Apply the documented
fix if present. Only if genuinely new: solve it, then record it (R3).

**R6 - Cite from disk, never from memory.** Every factual claim about the code carries
a `path/to/file:line` reference that you verified by reading the file this session.
Never invent a citation, never trust a prior summary's claim about the code.

**R7 - Spec-vs-actual: surface, do not silently reconcile.** When actual behavior
differs from what a spec / ticket / acceptance criterion states, do NOT quietly change
the artifact to match reality. The reality might be the bug. Quote both values and let
the user decide.

**R8 - Match the output to the request. No embellishment.** Asked for one artifact
(a commit message, a yes/no, a file to open) - give exactly that and stop. No tables,
option-lists, or next-steps unless asked. Do not re-summarize results already shown.
The single lane line required by R21 is part of the answer, not embellishment, and is
the one addition this rule permits; when the request is for a bare artifact, the lane
line is dropped too.

**R9 - Workflow-guide sync.** If the user changes a workflow this framework describes,
record the change in the relevant guide file FIRST, then execute. The guide is the
source of truth; execution follows it. If a change was applied without a guide entry,
add the entry before finishing.

**R10 - Typography: ASCII prose.** Never emit em-dash, en-dash, unicode ellipsis or
smart quotes in prose (files, comments, commit messages, chat). Use hyphen `-` and three
periods `...`. Scan before finishing.

The rule exists so prose does not read as machine-generated, so it stops at the prose.
Never rewrite characters inside a fenced code block, a diagram, a table drawn with box
characters, or any quoted output. Box-drawing glyphs carry alignment that ASCII
substitutes break, and a two-character substitute silently pushes a border out of
column. Leave them exactly as found, even when they are non-ASCII.

**R11 - Comments: only the non-obvious WHY.** New code gets zero comments by default.
Add a comment only for a business rule, workaround, or constraint that cannot live in a
name. Never restate what the code already says. Match the surrounding codebase style;
never rename existing symbols unless the rename is the task.

**R12 - Reviews report only what matters.** When asked to review, report only critical
findings (bugs, security, data loss, perf regressions, broken contracts, races, leaks).
No nits, no style, no praise. If nothing critical: say so in one line.

**R13 - Knowledge lives ONLY in the central hub, not in code repos.** All knowledge,
skills, and journals for every project the agent works on live in ONE shared repo -
the **central hub** (section 10) - never inside the individual project code repos on
any branch. Even when you are editing code in a project repo, every write goes to its
home in the hub: knowledge to `HUB_ROOT/knowledge/` (project-scoped under
`knowledge/projects/<project>/`), skills to `HUB_ROOT/skills/<verb-noun>/SKILL.md`, and
journals to `HUB_ROOT/journal/`. Never create `.ai/` folders, `feature/docs`
branches, or any framework artefact inside a project code repo.

**R14 - Journal every non-trivial task.** At the start of multi-step or implementation
work, open or resume a task journal under the central hub's `journal/` (section 11).
Append every clarification and its answer, every decision and its reason, and every
in-flight lesson in the same turn you learn it. Promote durable lessons into the
knowledge files (R3). The journal is the raw, per-task record; the knowledge files are
the distilled memory.

**R15 - The hub auto-commits and pushes; code repos never.** This is the ONE
exception to the general "no commits, no pushes" rule (section 6). Any change made
inside `HUB_WORKTREE/HUB_ROOT/` (knowledge, skills, journals, INDEX, ESSENTIALS,
README) MUST be committed and pushed by the agent at the end of every
interaction that touched it, on `HUB_BRANCH`, using ordinary `git add -A && git
commit -m "..." && git push`. No opt-in prompt, no "print the commit message and
stop" - the agent commits and pushes. The commit message follows the hub repo's own
prefix convention (check `git log --oneline -20`) and is echoed in the final response.
This exception applies ONLY to the hub worktree on `HUB_BRANCH`; every other repo,
branch, or worktree remains under the strict no-commit rule (section 6). The engine
is not part of the hub and is never pushed from a hub machine (section 9).

**R16 - Three-strike anti-loop, then escalate.** On a failing action, do not repeat the
same failing action. `known-issues.md` was already consulted at the first sign of failure
(R5), so do not re-read it here. Attempt 1: apply the diagnosis. Attempt 2: a genuinely
different approach, not a variation of the first. Attempt 3: question the assumption the
first two shared, and widen the search. After three failed attempts: STOP and escalate to
the user with what was tried, the errors verbatim, and the current hypothesis. Record the
failure chain in the active task journal (R14).

**R17 - Honesty over agreement.** Disagree with the user when evidence contradicts the
request; investigate before validating. Prioritise technical accuracy over confirming a
belief. False agreement is a defect (this mirrors R7: surface spec-vs-actual, never
silently reconcile).

**R18 - Present tense only. The framework carries no archaeology.** Every file in the
hub describes how things work NOW. Never write version-history narrative, "breaking
change from", "previously we", "the old X has been retired", "migration notes", or a
record of an approach that was tried and refined away. When a rule, layout, or decision
changes: rewrite the text in place so it reads as if it had always been that way, and
delete what it replaced. Git history is the archive; the working files are the truth.
The only permitted backward-looking artefacts are ADRs (section 12), which record a
decision and its rationale, not a chronicle of the framework. If a legacy artefact still
exists on disk, give it one line naming it inert, never a paragraph explaining its era.

**R19 - ESSENTIALS is the always-loaded playbook. Items are earned, demoted, never
compressed away.** `ESSENTIALS.md` is the third file read at session start (section 1) and
the only knowledge file loaded unconditionally. It is a list of ITEMS, not prose. Each
item has a stable id, a one-line rule, a pointer to the detail, and two counters:

`[E-014] (h:6 m:0) Verify branch before claiming state -> knowledge/conventions.md`

`h` counts turns where the item demonstrably helped. `m` counts turns where it misled or
was wrong. Soft target is 40 items: past it, DEMOTE the lowest-value items (remove the
line here, the detail already lives in `knowledge/`). Never shrink the file by merging two
items into a vaguer one - that is brevity bias, and it destroys the specificity that made
the item useful (ACE, ICLR 2026). An item with `m` >= 2 is deleted or rewritten, not kept.
A vague item is worse than no item.

**R20 - Specification before plan, plan before code.** Never jump to implementation. For
any non-trivial change, run the gates in section 12: requirements + `grill-me` ->
durable SPEC (and an ADR for each architectural decision) -> `grill-me` -> ephemeral PLAN
-> `grill-me` -> code -> QA. The spec is a durable knowledge artefact that must still be
useful nine months from now; the plan is a disposable checklist. Never let a plan
substitute for a spec. Gate 1 opens on the conditions in section 13.2, never on a phrase.
Skip gates only for a genuinely trivial change (one-line fix, typo, informational
question) and say which gate you skipped and why.

**R21 - Triage every request before acting. Never wait for the magic words.** Before the
first tool call and before the first line of any substantive response, run the triage in
section 13 and decide which lane and which gate this request belongs to. The user is
never required to say "let's plan", "write a spec", "write an ADR", or name any skill.
Intent is inferred from the request and the repo state, not from trigger phrases. State
the chosen lane in one short line, then proceed. If triage says a gate is required, enter
that gate even though the user asked for something further down the chain: a request to
"just add the endpoint" that trips a spec wire gets a spec first, and you say why in one
line. Guessing the lane silently is a defect; so is asking the user to pick it when the
evidence already decides it.

**R22 - Trip-wires fire the skill, not the user.** Every skill in this hub is triggered by
a CONDITION, not by a keyword (section 13). When a condition in the trip-wire tables is
met, load and run that skill immediately, in the same turn, without being asked and
without asking permission. Announce it in one line ("architectural choice detected,
recording ADR 007"). The only skills that wait for an explicit request are the ones whose
trip-wire is literally "the user asked". If you notice a trip-wire fired after the fact,
stop and run it retroactively before finishing the turn. A turn that ends with an unfired
trip-wire is an incomplete turn.

**R23 - Delta updates only. Never rewrite a knowledge file wholesale.** Knowledge and
ESSENTIALS evolve by adding, editing, or demoting INDIVIDUAL items, each change touching
the smallest possible span. Never regenerate a whole knowledge file from memory, never
"tidy up" by rewriting sections that the current task did not touch, and never replace
specifics with a summary. Repeated wholesale rewriting causes context collapse: detail
erodes a little each generation until the file is generic and worthless. R18 (present
tense, no archaeology) governs PROCESS docs - rules, READMEs, guides. R23 governs
KNOWLEDGE - facts, playbook items, specs. When the two appear to conflict, R23 wins for
anything under `knowledge/` and `ESSENTIALS.md`.

**R24 - Close the loop with execution feedback.** Self-improvement is driven by what
actually happened, not by opinion. At the end of any task, run the three ACE roles:
GENERATE (what did I do), REFLECT (which context items helped, which misled, what was
missing), CURATE (apply the deltas). Concretely: increment `h` on every ESSENTIALS item
that changed a decision correctly, increment `m` on any that sent you the wrong way, add
an item for anything you had to discover that should have been known, and demote the
dead weight. A task that taught you nothing needs no delta; a task that surprised you
always does.

**R25 - Every knowledge claim carries its provenance.** Each factual entry under
`knowledge/` ends with exactly one tag: `[verified YYYY-MM-DD]` for something observed
directly, with the command output, log line, or `path:line` that proved it, and
`[inferred]` for something believed but never observed. An `[inferred]` entry is a lead,
not a fact: it may not be cited as justification for a change, and it may not be promoted
to `ESSENTIALS.md`. When a session observes an inferred claim, it flips the tag and dates
it. When a session disproves one, it deletes the line rather than annotating it, since the
correction is the new entry and git holds the rest (R18). A `[verified]` date is the last
observation, not the discovery: re-verify anything volatile (infrastructure, config,
versions, alarm state) before acting on a date older than 90 days. Tags carry over into
specs and ADRs: an assumption written into a spec is `[inferred]` until it is checked.

---

## 3. The self-organizing loop (R3 in detail)

When you discover ANYTHING new, run this before continuing the task:

1. **STOP** the current step.
2. **CLASSIFY** the discovery (section 4 table).
3. **RECORD** it in the matching `knowledge/*.md` file: what it is, why it is true,
   any failed approaches, the fix or rule, and a verified `path:line` if it is about code.
4. **CITE** it in `INDEX.md` if it is a new component, service, or top-level fact.
5. **RESUME** the task.

This is not optional. It is what makes the knowledge base grow and stop future sessions
(and future agents) from repeating the same dead ends. The knowledge files ARE the memory.

## 4. Classification - where each discovery goes

All paths are relative to the central hub (`HUB_ROOT`, section 10). Project-scoped
material goes under `knowledge/projects/<project>/`; cross-project material goes at the
hub root.

| Discovery | Goes to |
|---|---|
| An error and its fix / a tool that misbehaves / a failed approach | `knowledge/projects/<project>/known-issues.md` (or `knowledge/known-issues.md` if cross-project) |
| A convention, pattern, rule, mapping, or domain fact | `knowledge/projects/<project>/conventions.md` (or `knowledge/conventions.md`) |
| Build path, env, version, setup, or config fact | `knowledge/projects/<project>/config.md` (or `knowledge/config.md`) |
| A new component/service/module worth mapping | `INDEX.md` (component map) |
| A repeatable workflow worth reusing | `skills/<verb-noun>/SKILL.md` (section 8) |
| A clarification, answer, decision, or in-flight lesson during a task | the active task journal (section 11) |
| A change to how a workflow is run | the skill/guide that describes it (R9) |

When none fit, create a new `knowledge/<concern>.md` (R4) and register it in `INDEX.md`.

---

## 5. Keeping knowledge files healthy

Before appending, scan the target file. Reorganize when:

- A file mixes 3+ unrelated concerns, or a subsection outgrows the main content, or the
  file passes ~500 lines: split the secondary concern into a new `knowledge/<concern>.md`,
  leave a one-line cross-reference in the original, register the new file in `INDEX.md`.
- The same entry appears more than once: merge into one canonical entry, keep the most
  complete/recent version, cross-link the rest.
- An issue is marked fixed and its `[verified]` date is more than 90 days old: prune it
  (or move it to a `*-archive.md` that is not auto-loaded).
- An `[inferred]` entry sits in a file the current task touched and the current task could
  have verified it: verify it or delete it. Unverified claims that nobody will ever check
  are the slow version of a wrong knowledge file.

Keep files scannable. A knowledge file nobody can skim is a knowledge file nobody reads.

---

## 6. Git model (the agent never commits, except the hub is auto-commit)

This framework self-updates knowledge files on disk immediately (R3). It also
auto-commits and pushes those updates when they land in the central hub (R15).
Everywhere else, the agent never commits.

- **Never run `git commit` in any project code repo.** Ever. Not for code, not for docs.
  The user commits code, always, manually.
- **Never run any build / deploy / CI / release command.** The job ends at: files on
  disk, tests green if you ran them, knowledge and INDEX updated. Drop deploy steps.
- **Never `push --force`. Never touch `main`/`master`/`develop`** beyond `pull --ff-only`.
- **Destructive actions** (delete, revert, drop, overwrite existing content) require a
  fresh one-sentence in-session confirmation, even if a plan said to continue. Adding new
  files or lines may proceed.
- **Verify against disk before acting**: current branch, uncommitted state, actual file
  contents. Never trust a prior summary's claim about repo state.
- **End every task that left changes** by printing, as the very LAST thing, a ready-to-use
  commit message in a single fenced code block containing ONLY the message. Match the
  repo's existing prefix convention (check `git log --oneline -20`). Any rationale goes
  AFTER the closing fence, never inside it.

**Hub is the exception (R15): auto-commit and push, every interaction.** The full rule,
including the branch scope and the commit convention, is R15. Section 6's no-commit
clauses above apply to every repo that is not the hub worktree on `HUB_BRANCH`.

---

## 7. Bootstrapping a project into the hub

On the first session that touches a new project, from inside the central hub:

1. Create `knowledge/projects/<project>/` with `config.md`, `conventions.md`,
   `known-issues.md` copied from the headed templates at `knowledge/config.md`,
   `knowledge/conventions.md`, and `knowledge/known-issues.md` in the engine.
2. Fill `config.md` from what you can verify on disk in the project code repo (build
   tool, language, versions, how to run, env vars). Cite `path:line`.
3. Add a component-map row for the project in the hub's `INDEX.md`.
4. Commit and push per R15 / section 6 (hub auto-commits on `HUB_BRANCH`).

From then on, every session grows these files through the loop in section 3.

---

## 8. Building skills (repeatable workflows)

The knowledge files hold **facts to recall**. A **skill** holds **steps to execute**:
a named, repeatable workflow the agent runs when its condition is met (create a release
note, refresh a doc, onboard a service). Skills live in `skills/<verb-noun>/SKILL.md`, one
folder per workflow, and are registered in `INDEX.md` exactly like knowledge files - loaded
only when their FIRES WHEN condition is met (R22). They are plain markdown so any agent
can run them.

The folder-per-skill layout (`skills/<slug>/SKILL.md`) is the cross-framework Agent Skills
convention: symlinking `~/.agents/skills/<slug>` to `HUB_ROOT/skills/<slug>` surfaces the
skill to every agent that reads that location.

**When to build one:** a workflow is worth a skill once it has been done twice, has
more than a couple of steps, or must run the same way every time.

**How to build one (do this when the user asks to "add a skill / workflow"):**
1. **Search first (R4).** Scan `skills/` and `INDEX.md` for an existing skill that
   already covers this workflow. If found, append/refine it. Never create a second
   folder for the same workflow.
2. Create `$HUB_ROOT/skills/<verb-noun>/SKILL.md`, copying
   `$CAIRNLORE_ENGINE/skills/_template/SKILL.md`. Write to the hub, never beside the
   template: the template lives in the engine, and a relative `skills/` resolves there.
3. Fill: `name`, `description` (this is what the agent matches on), `triggers`,
   `preconditions`, numbered `steps`, `validation`, `example prompts`. Keep steps concrete
   and idempotent. Cite `path:line` for anything code-specific.
4. Register the folder in the skills table in `INDEX.md` with its FIRES WHEN condition.
5. Commit and push per R15 / section 6 (hub auto-commits on `HUB_BRANCH`).

**Running a skill:** when a request matches a skill's triggers, load that one file,
follow its steps in order, and honor its preconditions. If reality diverges from the
written steps, stop and apply R9 (update the skill FIRST, then execute) - the file is
the source of truth for the workflow, not your memory of it.

## 9. Contributing changes (project vs framework)

Two layers, two homes. Classify every change before writing it:

- **Project knowledge / skills** (specific to ONE project) -> `knowledge/projects/<project>/`
  or `skills/` in the hub. This is the common case and happens automatically through the
  loop (section 3).
- **Cross-project knowledge / skills** (shared across <your-domain> projects) -> `knowledge/*.md`
  at the hub root, or `skills/<slug>/`. Also part of the normal loop.
- **The engine itself** (a rule in this file, the loop, the git model) -> the engine repo,
  which is pull-only on every machine that is not its owner. A hub machine never pushes
  the engine: it exports the change with `capture-upstream` instead. Engine changes affect
  every hub that uses the framework: be conservative and make the change small.

**Rules for any contribution:**
1. **One file per concern (R4).** Find the existing home and append; do not fork a topic.
2. **Adding a new rule to the engine:** give it the next `R<n>` id, keep it to one
   imperative sentence plus a short clarifier, and bump the `Version` header (patch for a
   fix/clarification, minor for a new rule or skill, major for a breaking model change).
3. **Changing a workflow:** update the skill/guide FIRST, then execute (R9).
4. **Commits:** see section 6. Code repos never; hub auto-commits on `HUB_BRANCH` (R15).
5. **Keep it agent-agnostic.** The engine names no agent-specific instruction filename and
   ships no vendor config. If an agent needs a different entry filename, it symlinks
   `AGENTS.md` (section 0) - it never gets its own copy. Naming a harness as a plain fact
   (for example, which directory it reads skills from) is allowed; depending on one is not.

---

## 10. Operating model: the central hub

The framework and every fact, skill, and journal it records live in ONE shared repo -
the **central hub** - checked out as an ordinary worktree. There are no `.ai/` folders
inside code repos. There are no `feature/docs` branches carrying knowledge. Every
project's knowledge lives here. The engine is not part of the hub: it is pulled from its
own repo and read in place (section 9).

The names and paths are parameters, read once per session from the `Operating model`
block in `INDEX.md`:

| Parameter | Meaning | Typical default |
|---|---|---|
| `HUB_REPO` | the shared hub repo | `<hub-repo>` (worktree: `<hub-root>`) |
| `HUB_WORKTREE` | filesystem path to the hub checkout | `~/git/<hub-repo>-worktrees/<hub-root>` |
| `HUB_ROOT` | where `AGENTS.md`, `INDEX.md`, `knowledge/`, `skills/`, `journal/` sit | `<hub-root>/` (relative to `HUB_WORKTREE`) |
| `HUB_BRANCH` | the long-lived branch this hub is on | `docs/risk-ai-self-organizing-knowledge-framework` |

**Where writes go.** You may be coding in ANY project repo. All knowledge, skill, and
journal writes still go to `HUB_WORKTREE/HUB_ROOT/...` (R13). No branch switching in the
project repo, no framework artefacts in code branches.

**Layout inside the hub:**

```
HUB_ROOT/
+-- INDEX.md, ESSENTIALS.md, README.md   # map + playbook + landing
+-- knowledge/
|   +-- *.md                           # cross-project knowledge (e.g. shared runbooks)
|   +-- projects/<project>/            # per-project knowledge
|       +-- config.md, conventions.md, known-issues.md
|       +-- specs/<slug>.md            # durable specs (section 12)
|       +-- adr/<NNN>-<slug>.md        # immutable decisions (section 12)
+-- skills/
|   +-- <verb-noun>/SKILL.md           # discoverable skills
+-- journal/
    +-- <YYYY-MM-DD>_<slug>.md         # cross-project journals
    +-- projects/<project>/            # per-project journals if a project has many
```

`AGENTS.md` and the core skills are NOT in this tree. They live in the engine repo and
are read from there, so a `git pull` of the engine updates every hub at once.

**The hub never syncs code.** The hub does not need to see any code branch - the
agent reads the code directly from each project's main clone when it needs a `path:line`
citation (R6). If a project's main clone is not checked out, tell the user to check it out
before asking for citations from that project.

**First-time hub setup** (once, done by the user):
```bash
# hub uses a long-lived docs branch as an ordinary worktree
cd <hub-repo>
git worktree add ../<hub-repo>-worktrees/<hub-root> -b docs/risk-ai-self-organizing-knowledge-framework
mkdir -p ../<hub-repo>-worktrees/<hub-root>/<hub-root>
cp -R <existing-hub>/framework/{AGENTS.md,INDEX.md,knowledge,skills,journal} \
      ../<hub-repo>-worktrees/<hub-root>/<hub-root>/
# (This hub keeps a shippable copy of the framework at HUB_ROOT/framework/;
#  bootstrap a new hub from any existing hub's framework/ subdir.)
# hook the agent: symlink root entry if the repo has no own AGENTS.md
ln -s <hub-root>/AGENTS.md ../<hub-repo>-worktrees/<hub-root>/AGENTS.md
# fill the Operating model block in HUB_ROOT/INDEX.md, then commit
```

---

## 11. Task journals (the per-task artefact)

Knowledge files hold distilled, durable facts. A **task journal** holds the raw,
chronological record of ONE task: the goal as understood, every clarification and its
answer, decisions and their reasons, and lessons found while implementing. It captures the
reasoning that knowledge files intentionally leave out, and makes a task resumable and
auditable.

- **Location:** `HUB_ROOT/journal/<YYYY-MM-DD>_<task-slug>.md` in the hub worktree (R13).
  Per-project journals may sit at `HUB_ROOT/journal/projects/<project>/<YYYY-MM-DD>_<slug>.md`
  if a project has enough traffic to warrant its own subdir. Authoring template:
  `journal/_template.md`.
- **Lifecycle** (driven by the `start-task` skill):
  - **Start** - scaffold from the template, capture the goal and the clarifying questions
    you need, ask them (R2), and record the answers. Status `In progress`.
  - **During** - append each clarification+answer, decision+reason, and in-flight lesson
    in the same turn you learn it (R14). When a lesson is durable, also record it in the
    right knowledge file (R3) and note the promotion in the journal.
  - **Close** - fill Outcome, promote durable lessons into `knowledge/*`, set status `Done`.
- **Resume:** at session start, if a journal is still `In progress`, load it first
  (section 1).
- **Journal vs knowledge:** journal = raw, per-task, chronological, append-only during
  work. Knowledge = distilled, durable, deduplicated, cross-task. Promotion is one-way:
  journal -> knowledge. Never copy knowledge back into a journal, and never let a journal
  become the home for a durable fact that belongs in a knowledge file.
- **Commits** - per section 6.

---

## 12. Spec-first delivery (R20 in detail)

Code is the LAST step, not the first. Thirty minutes specifying saves hours of QA and
micro-managed back-and-forth fixing what the agent guessed wrong.

### Gate 1 - Specification (durable)

Opened by any condition in the `write-spec` trip-wire list (section 13.2), never by a
phrase. Do NOT produce a task list here.

1. Draft the requirements as you understand them.
2. Run `grill-me`: interrogate the user branch by branch until the requirements are
   thorough. Resolve each dependency between decisions before moving on. If a question
   can be answered by reading the code, read the code instead of asking.
3. Write the SPEC to `knowledge/projects/<project>/specs/<slug>.md`. It captures
   requirements, business rules, edge cases, gotchas, explicit non-goals, and the
   acceptance criteria. It is written for someone maintaining this feature nine months
   from now with no memory of the conversation.
4. Every architectural decision gets its OWN ADR at
   `knowledge/projects/<project>/adr/<NNN>-<slug>.md`: context, options considered,
   decision, consequences. One decision per ADR. An ADR is immutable once accepted; to
   change it, write a new ADR that supersedes it by number.

A spec is durable knowledge and lives in `knowledge/`. It is never deleted when the work
ships; it is updated when behaviour changes (R7).

### Gate 2 - Plan (ephemeral)

Only after the spec is agreed. Produce a plan that implements the SPEC.

1. Produce the ordered, bounded implementation steps.
2. Run `grill-me` on the plan itself: sequencing, blast radius, what could break, what is
   untestable, what is missing.
3. The plan lives in the task journal (section 11) and in the agent's todo list. It is
   disposable. When it is done it has no further value, and it is never promoted into
   `knowledge/`.

### Gate 3 - Code

Implement against the spec, one plan step at a time. If implementation reveals the spec
was wrong, STOP: fix the SPEC first (and add an ADR if the architecture moved), then
resume. Never let code silently diverge from the spec (R7, R17).

### Gate 4 - QA

Verify against the spec's acceptance criteria, not against the diff. Then run
`close-task`: promote lessons (R3), review `ESSENTIALS.md` against its soft target (R19).

### What lives where

| Artefact | Lifespan | Location |
|---|---|---|
| Spec | durable, maintained | `knowledge/projects/<project>/specs/<slug>.md` |
| ADR | durable, immutable | `knowledge/projects/<project>/adr/<NNN>-<slug>.md` |
| Plan | disposable | task journal + todo list |
| Lessons | durable, distilled | `knowledge/*.md`, then `ESSENTIALS.md` if load-bearing |

---

## 13. Autonomous routing (R21 and R22 in detail)

The user never has to name a skill or say a trigger phrase. The framework decides what
this request is and what to run. Routing is a deterministic procedure, not a judgement
call: run the checks in order, first match wins.

### 13.1 Triage - run before every substantive response

| # | Test (first match wins) | Lane | What you do |
|---|---|---|---|
| 0 | Does it delete, revert, drop, force-push, or overwrite existing work? | SAFETY | Confirm in one sentence before anything else. Overrides all other lanes. |
| 1 | Is it answerable from knowledge or code, with no change to disk? | ANSWER | Answer it. Cite `path:line`. No gates. |
| 2 | Is it one mechanical edit, no behaviour change, no contract change, no new dependency? | DIRECT | Do it. Say in one line which gates you skipped and why. |
| 3 | Did any SPEC wire in 13.2 trip? | GATE 1 | Run `write-spec`. Do this even if the user asked for code. |
| 4 | Is there an agreed spec for this work, and no plan yet? | GATE 2 | Produce the plan, grill it, put it in the journal and todo list. |
| 5 | Is there an agreed plan with steps outstanding? | GATE 3 | Implement the next step. |
| 6 | Are all plan steps done? | GATE 4 | Verify against the spec's acceptance criteria, then `close-task`. |

Announce the lane in one short line, then proceed. Do not narrate the triage itself.

### 13.2 Trip-wires - conditions that fire a skill with no request

Check these continuously, not only at the start of a turn. When one trips mid-work, stop
and run the skill in the same turn (R22).

**Fire `write-spec` (gate 1) when ANY of:**
- the request adds, removes, or changes behaviour a user or caller can observe
- it plausibly touches more than two files, or any file you have not read yet
- you are about to assume something material that the user has not stated
- the request contains an unresolved "or" ("should it retry or fail?")
- a business rule is implied but not written down anywhere in `knowledge/`
- the same area was specified before and the spec no longer matches the code (R7)

**Fire `write-adr` when ANY of:**
- a dependency, module, or service boundary is added or removed
- a persisted schema, wire format, or public contract changes
- something moves between sync and async, or batch and streaming
- ownership of data or the source of truth for a fact moves
- you introduce a pattern not already present in `conventions.md`
- a competent engineer could reasonably have chosen the other option
- you find yourself writing "we could either X or Y" in any output

**Fire `grill-me` when ANY of:**
- you are at gate 1 or gate 2 (both gates end with a grill)
- you have made two or more assumptions in a row without confirmation
- the request is one sentence but implies a week of work

**Fire `promote-lesson-to-knowledge` (R3) when ANY of:**
- you learned a fact that would have saved you time had you known it at the start
- you hit an error whose cause was not obvious from the message
- you discovered a constraint that is not written in `knowledge/`

**Flip a provenance tag (R25) when ANY of:**
- you observed something this session that `knowledge/` records as `[inferred]`
- you are about to rely on a `[verified]` claim dated more than 90 days ago
- you are writing a new knowledge entry (choose the tag deliberately, never omit it)

**Fire `audit-knowledge-health` when ANY of:**
- `ESSENTIALS.md` passes its soft target of 40 items and something must be demoted
- a pointer in `ESSENTIALS.md` or `INDEX.md` fails to resolve
- `knowledge/` holds more files than the count recorded in the last audit line of
  `INDEX.md`, plus five
- an ESSENTIALS item reaches `m:2` (R19 forces a delete or rewrite, and the audit shows
  what else is rotting alongside it)

**Fire `reflect-and-curate` (R24) when ANY of:**
- a task ends, by any wording
- something surprised you, or the same failure happened twice
- a turn contradicted an item currently in `ESSENTIALS.md`

**Fire `capture-upstream` when:**
- you learn something that should change a RULE, SKILL, or WORKFLOW, and this machine's
  engine clone cannot push

**Fire `bootstrap-project` when:**
- you are about to write knowledge about a project with no subtree under
  `knowledge/projects/`

**Fire `start-task` when:**
- work is about to span more than one turn or more than three steps, and no journal is
  open

**Fire `close-task` when:**
- the last plan step is done, or the user signals the work is finished in any wording

**Fire `adversarial-review` when:**
- a diff is about to be handed to a human, and you wrote that diff

**Fire `verify-skill-registry` when:**
- you are about to create a skill, or you notice two skills with overlapping conditions

### 13.3 The gate ledger

The agent, not the user, holds the state. At the top of every turn, restate it in one
line, exactly like this:

`Lane: GATE 2 (plan). Spec: specs/bet-limits.md (agreed). Step 3 of 6.`

Store the same state in the task journal so a fresh session recovers it. If you cannot
tell which gate you are in, you are in triage: run 13.1 again.

### 13.4 Self-audit before ending a turn

Answer these silently. Any "yes" means the turn is not finished:

1. Did a trip-wire in 13.2 fire that I did not run?
2. Did I write code without an agreed spec, when a spec wire had tripped?
3. Did I make an architectural choice without an ADR?
4. Did I learn something durable and not record it (R3)?
5. Did I state the lane and the next action?

### 13.5 When routing is genuinely ambiguous

Ask exactly one question, offering the two lanes you are torn between, with a
recommendation. Never ask the user to name a skill. Never ask "would you like me to write
a spec?" - if the wire tripped, the answer is yes; write it and say so.
