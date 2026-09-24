# SETUP.md - get Cairnlore running on a machine, in order

Two repositories, one direction of flow. The engine flows down into every machine.
Knowledge never flows up.

```
cairnlore      PUBLIC    the engine: rules, skills, templates, installer
<your hub>     PRIVATE   your knowledge, journals, stones
```

You can have as many hubs as you keep separate bodies of knowledge. The engine is the
same everywhere; each hub is its own private repo and never merges with another.

---

## A. First machine

**1. Publish the engine**

```bash
gh repo create cairnlore --public --source ~/git/cairnlore --push
```

**2. Create a hub**

```bash
gh repo create cairnlore-hub --private --clone
cd cairnlore-hub && mkdir -p knowledge journal && git commit --allow-empty -m "init" && git push
```

**3. Install**

```bash
git clone https://github.com/dvrxky/cairnlore.git ~/.cairnlore
CAIRNLORE_HOME=~/cairnlore-hub bash ~/.cairnlore/install.sh
```

Done. The engine is at `~/.cairnlore`, your knowledge is in `~/cairnlore-hub`, and the global
rules at `~/.config/opencode/AGENTS.md` point at both.

Every path the installer uses can be overridden:

| Variable | Default | What it sets |
|---|---|---|
| `CAIRNLORE_HOME` | `~/cairnlore-hub` | where your knowledge lives |
| `CAIRNLORE_BRANCH` | `main` | the hub's long-lived branch |
| `CAIRNLORE_ENGINE` | `~/.cairnlore/payload/framework` | where the engine is read from |
| `CAIRNLORE_OPENCODE_DIR` | `~/.config/opencode` | where the global rules are written |
| `CAIRNLORE_SKILLS_DIR` | `~/.agents/skills` | where skills are installed |
| `CAIRNLORE_REPO` | this repository | the clone source, for a fork |

An unset variable falls back to its default silently, so a typo in a name installs to the
default path and reports success. Check the paths the installer echoes before trusting it.

---

## B. Any further machine

**1. Install the engine, pull-only**

```bash
git clone https://github.com/dvrxky/cairnlore.git ~/.cairnlore
git -C ~/.cairnlore remote set-url --push origin DISABLED
```

Set the push URL to an invalid value on every machine you do not publish the engine from.
A push then fails at the git layer, so the boundary does not depend on anyone remembering
it.

**2. Point the engine at that machine's hub**

```bash
CAIRNLORE_HOME=<path to the hub> bash ~/.cairnlore/install.sh
```

The installer never overwrites a hub that already has an `AGENTS.md`. It updates the
engine files and leaves all existing knowledge untouched.

---

## C. Everyday use

**Update the engine, any machine:** you do not. The engine-sync plugin pulls the
engine at every session start and whenever a session goes idle, and R27 has open
sessions re-read the rules on their next turn from the stamp it maintains. The manual
pull below is only for a session that was already open when the plugin was installed:

```bash
git -C ~/.cairnlore pull
```

**Change the engine:** only where you publish from. Edit, commit, push. Every other
machine picks it up at the next session.

**Improve the engine from a pull-only machine:** you cannot commit it there. The
`capture-upstream` skill fires on its own and prints a scrubbed, paste-ready block. Paste
that into a session on the publishing machine, which applies and pushes it.

---

## D. What goes where

| You learned | It goes |
|---|---|
| A rule, skill, or workflow should change | the engine, via `capture-upstream` if you are on a pull-only machine |
| A fact about a private system | that machine's hub, never upstream |
| A fact about a personal project | `cairnlore-hub` |
| A one-off with no reusable lesson | the task journal, nothing more |

The test: if you cannot state the lesson without naming a specific system, it is
knowledge, not engine. Keep it in the hub.

---

## E. Keeping the public repo clean

The engine repo is public. It must never contain private names, service or host
identifiers, ticket prefixes, internal URLs, or user-specific paths.

**Never put those strings in a tracked file, including this one.** Writing them into the
repo to configure a check would publish the exact things the check exists to block. Keep
them in two places git cannot reach: a config file outside every repo, and the local
hooks directory.

**1. List your private identifiers outside the repo**

```bash
mkdir -p ~/.config/cairnlore && cat > ~/.config/cairnlore/leak-patterns <<'EOF'
<organisation-name>
<team-or-product-name>
<service-prefix>
<TICKET-PREFIX>
<internal-hostname>
<private-email>
<your-username>
EOF
chmod 600 ~/.config/cairnlore/leak-patterns
```

One pattern per line, case-insensitive, fed to `git grep -f`. This file lives in
`~/.config/`, never in a repo.

Include your own username: user-specific absolute paths are the most common accidental
leak, and they read as harmless while naming your account and your directory layout.

**2. Install the hook that reads it**

```bash
cat > <repo>/.git/hooks/pre-push <<'HOOK'
#!/usr/bin/env bash
set -uo pipefail
P="$HOME/.config/cairnlore/leak-patterns"

if [ ! -s "$P" ]; then
  echo "pre-push BLOCKED: $P is missing or empty."
  echo "The hook cannot check anything without it. Create it, or remove this hook on purpose."
  exit 1
fi

if git grep -nIif "$P" -- . ; then
  echo "pre-push BLOCKED: the strings above are in tracked files."
  exit 1
fi
HOOK
chmod +x <repo>/.git/hooks/pre-push
```

The missing-file case must EXIT 1, not 0. A hook that passes when its pattern list is
absent reports success while checking nothing, and an installed hook is read as proof the
repo is guarded. Fail closed: no list, no push.

`.git/hooks/` is never pushed, so the hook stays local by design. Install it in every repo
you publish from, and verify it actually fires:

```bash
cd <repo>
git grep -nIif ~/.config/cairnlore/leak-patterns -- .   # expect: no output
.git/hooks/pre-push < /dev/null ; echo "exit=$?"        # expect: exit=0
```

An `exit=1` with a missing-file message means the list is not there yet. That is the hook
working, not failing.

**3. Check history too, once**

A hook only guards future pushes. If a repo ever held a private string in an earlier
commit, rewriting the working tree does not remove it from history. The reliable fix for a
small repo is to delete `.git`, re-initialise, and make one clean commit.

---

## F. Verify it worked

```bash
ls ~/.cairnlore/payload/framework/AGENTS.md      # engine present
ls <hub>/ESSENTIALS.md                       # playbook installed
git -C ~/.cairnlore push 2>&1 | head -1          # pull-only machine: must fail
ls ~/.config/opencode/plugins/engine-sync.js
cat ~/.config/cairnlore/engine-head    # written by the plugin at session start; absent
                                       # before the first session is expected, not an error
```

Then start a session and ask for anything. The first line back should name a lane, for
example `Lane: ANSWER.` If it opens with a paragraph of preamble instead, the global
rules did not load.
