# Cairnlore

**One stone per traveler.**

Your AI agent forgets everything between sessions. Cairnlore is the pile of stones it leaves
behind so the next session starts where the last one finished.

```bash
git clone https://github.com/<you>/cairnlore.git ~/.cairnlore && bash ~/.cairnlore/install.sh
```

---

## The story

On a high moor in bad weather, the path disappears. Not dramatically. There is just
heather in every direction and a suspicion that you have walked past this same rock twice.

Then you see it. A knee-high pile of stones, stacked by nobody you will ever meet.

That is a cairn. No committee approved it. No one maintains it. Some walker four hundred
years ago stood where you are standing, felt the same lurch of doubt, and set down a
stone. Then someone else added one. The pile that saves you was built entirely by people
who were also lost, one rock at a time.

Here is the part that should bother you: your agent is on that moor every single morning,
and it refuses to pick up a rock.

---

## The problem, stated plainly

Your agent has no memory. Not bad memory. None.

Yesterday it learned that the deploy check reports success thirty seconds before the
thing is actually up. Today it will learn that again, with the same confidence, at the
same cost, and it will present the discovery to you like a cat bringing in a bird.

Most people respond by feeding it a giant instruction file. This works for about three
weeks. Then the file is nine hundred lines, forty of which contradict each other, and
everybody has quietly stopped reading it, including the agent, which now skims it the way
you skim a terms of service.

The usual second attempt is worse. You ask the agent to summarize its own notes to keep
them short. It does. Every summary loses a little detail. Do that for two months and you
have a photocopy of a photocopy of a photocopy, still technically legible, no longer about
anything. The researchers call this context collapse. You will call it something shorter.

---

## What Cairnlore does

**Stones, not scripture.** Knowledge is individual items, each one line, each with an
address. You add a stone. You do not rewrite the pile. Nothing gets summarized into mush
because nothing gets summarized at all.

**Stones earn their place.** Every item carries two numbers: how often it helped, and how
often it sent someone the wrong way.

```
[E-014] (h:6 m:0) Poll rolloutState, not desiredCount -> knowledge/deploy.md#ecs
```

Advice with a record. An item that misleads twice gets pulled off the pile and thrown in
the heather, which is more accountability than most engineering documentation has ever
faced.

**Nothing is deleted, only demoted.** When the pile gets tall, low-value stones move down
into the detailed notes. They still exist. They just stop shouting at every passing
traveler.

**It builds the cairn without being asked.** You never type a command name. Cairnlore notices
that you are about to make an architectural decision and starts writing it down, notices
that you are about to code something nobody specified and stops you, notices that you
learned something expensive and files it before the context window eats it.

**Code comes last, on purpose.** Thirty minutes describing what you actually want,
against several hours of watching a very fast machine build a very wrong thing with total
conviction.

---

## The honest part

This is not intelligence. It is masonry.

Cairnlore does not make your agent smarter. It makes your agent stop being an amnesiac with a
confident voice, which turns out to be most of the gap. The whole thing is markdown files
in a git repo. You can read every rule in twenty minutes. You could rebuild it yourself,
and the fact that you probably will not is exactly why it ships as one command.

There is no model here, no service, no account, nothing to sign up for. Two directories
and a shell script. It works while you are offline, on a plane, on a locked-down laptop
that trusts nothing.

---

## How it fits together

```
~/.cairnlore       the engine: rules, skills, templates, installer   (public, pull-only)
~/cairnlore-hub    your knowledge: stones, notes, specs, decisions    (yours, private)
```

The engine flows down into every machine you use. Knowledge never flows up. That single
direction is what lets you run the same setup on machines with different publishing
rights without their knowledge ever touching. Details in [`SETUP.md`](SETUP.md), rationale in
[`docs/adr/001-public-engine-private-brain.md`](docs/adr/001-public-engine-private-brain.md).

At session start the agent reads exactly three files: the rules, the map, and the pile of
stones. Everything else opens only when the work actually calls for it.

---

## Configure

Every path is an environment variable with a sane default.

| Variable | Default | What it is |
|---|---|---|
| `CAIRNLORE_HOME` | `~/cairnlore-hub` | where your knowledge lives |
| `CAIRNLORE_BRANCH` | `main` | the hub branch |
| `CAIRNLORE_OPENCODE_DIR` | `~/.config/opencode` | global agent rules |
| `CAIRNLORE_SKILLS_DIR` | `~/.agents/skills` | global skills |

Re-running the installer is safe. Anything it would overwrite is backed up first, and it
refuses to touch a hub that already has knowledge in it.

---

## Standing on

[AGENTS.md](https://agents.md) for the instruction format, now stewarded by the Agentic AI
Foundation. [Agent Skills](https://agentskills.io) for progressive disclosure. And
[Agentic Context Engineering](https://arxiv.org/abs/2510.04618) (ICLR 2026) for the two
failure modes Cairnlore is built to avoid: brevity bias and context collapse.

---

Tomorrow morning, your agent walks onto the moor and the stones are already there.
