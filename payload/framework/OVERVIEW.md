# OVERVIEW.md - Cairnlore on one page

Read this if you forgot how any of this works. Everything else is detail.

---

## The problem this solves

An AI agent forgets everything between sessions. So you re-explain the same context, it
repeats the same dead ends, and hard-won answers die in a chat window.

The fix: the agent keeps its own notes in a git repo, reads them at the start of every
session, and is required to update them the moment it learns something. Knowledge
accumulates instead of evaporating.

---

## Your setup: three layers

**1. Global rules** - `~/.config/opencode/AGENTS.md`
Loaded automatically in every session, every project. Your personal preferences: output
shape, typography, how comments should be written, whether the agent may commit. It also
points at the hub below.

**2. The hub** - one git repo (the installer puts it at `~/cairnlore-hub`)
Holds everything the agent knows. Facts, workflows, decisions, task records. It lives on
one long-lived branch and commits itself.

**3. Skills** - `~/.agents/skills/`
Reusable procedures the agent can load on demand. Personal ones live here, shared ones
live in the hub.

Why split this way: rules are about YOU and apply everywhere. The hub is about your WORK
and is shareable with a team. Skills are about HOW to do a repeated thing. Mixing them
means you cannot share one without leaking the others.

---

## What happens at session start

The agent reads exactly three files, nothing else:

1. `AGENTS.md` - the rules and how to behave
2. `INDEX.md` - a map of everything else, and when to open each thing
3. `ESSENTIALS.md` - the short list of facts that matter on almost every task

Everything else is opened only when relevant. This is the whole point: a cheap startup
that still has full depth available. Loading everything every time would burn context on
things the task does not need.

---

## Inside the hub

| Folder | Holds | Lifespan |
|---|---|---|
| `ESSENTIALS.md` | the vital few facts, capped at 50 lines | permanent, always loaded |
| `knowledge/` | facts, conventions, known issues, per project | permanent |
| `knowledge/.../specs/` | what a feature must do and why | permanent |
| `knowledge/.../adr/` | one architectural decision each, never edited | permanent |
| `skills/` | step-by-step procedures | permanent |
| `journal/` | a record per task | until the task closes |

Why ESSENTIALS is capped: an always-loaded file that can grow will grow, and then it is
not essential any more. To add a line you must cut one. The cap forces the agent to keep
distilling instead of hoarding.

Why specs and ADRs are separate from plans: a plan is a checklist that becomes useless
once ticked. A spec still answers "why does it behave like this?" nine months later.

---

## How work flows

Nothing gets coded first. Four gates:

1. **Spec** - the agent interrogates you until the requirements are solid, then writes
   them down. Any architectural choice becomes its own ADR.
2. **Plan** - only now, the implementation steps. Disposable.
3. **Code** - one step at a time. If the code proves the spec wrong, the spec gets fixed
   first.
4. **QA** - checked against the spec, then the task is closed and lessons are filed.

Why this order: 30 minutes spent specifying saves hours of correcting an agent that
guessed wrong and confidently built the wrong thing.

---

## How it decides what to do

You never have to name a skill or say a magic phrase. Before acting, the agent sorts your
request into a lane: safety check, plain answer, trivial edit, or one of the four gates.

Then it watches for conditions. If a contract or schema changes, it writes an ADR without
being asked. If it catches itself about to assume something you never said, it stops and
specs instead. If it learns something useful, it files it immediately.

Why: a trigger word you have to remember is a trigger word you will forget, and then the
system quietly stops working.

---

## The one habit that keeps it alive

The moment the agent learns anything (a fix, a constraint, a gotcha) it writes it into
the right file before continuing. Not at the end, not "later". That single rule is what
makes tomorrow's session smarter than today's.

---

## What you own

You commit and deploy your own code. The agent never commits in a project repo. The one
exception is the hub, which commits and pushes itself so that knowledge is never lost to
a closed terminal.

---

## Getting started

1. Run `bash install.sh`. It creates the hub, writes the global rules, installs the skills.
2. Give the hub a git remote so it can push.
3. The first time you work on a project, the agent seeds a knowledge subtree for it.
4. Seed `ESSENTIALS.md` with a few facts that are true on almost every task.

---

## If you only remember four things

1. Three files load at startup. Everything else is on demand.
2. Specs and ADRs are permanent. Plans are disposable.
3. ESSENTIALS is capped, so it stays essential.
4. Learn something, write it down immediately.
