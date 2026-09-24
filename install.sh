#!/usr/bin/env bash
#
# Cairnlore - one stone per traveler.
#
#   bash install.sh
#
# Installs the engine, the knowledge hub, and the global rules. Idempotent.
#
# Reproduces, on any machine, the complete setup:
#   1. The knowledge hub (engine rules + templates + core skills) as a real git repo,
#      ready to commit itself.
#   2. Global opencode rules (~/.config/opencode/AGENTS.md + opencode.jsonc),
#      with the hub path wired in.
#   3. Generic global skills (~/.agents/skills/*) discoverable by opencode.
#
# Idempotent: re-running backs up anything it would overwrite to <target>.bak-<ts>.
# Every step prints what it did. No network required.

set -euo pipefail

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# support `curl ... | bash`: fetch the package if the payload is not beside this script
if [ ! -d "$PKG_DIR/payload" ] && command -v git >/dev/null 2>&1; then
  PKG_DIR="$(mktemp -d)/cairnlore"
  REPO="${CAIRNLORE_REPO:-https://github.com/dvrxky/cairnlore.git}"
  git clone --depth 1 "$REPO" "$PKG_DIR" || {
    echo "install: cannot clone $REPO. Set CAIRNLORE_REPO to your fork." >&2
    exit 1
  }
fi
PAYLOAD="$PKG_DIR/payload"
TS="$(date +%Y%m%d-%H%M%S)"

# --- parameters (override via env) -------------------------------------------
HUB_HOME="${CAIRNLORE_HOME:-$HOME/cairnlore-hub}"                     # where YOUR knowledge lives
ENGINE_DIR="${CAIRNLORE_ENGINE:-$HOME/.cairnlore/payload/framework}"  # where the ENGINE lives (pull-only)
HUB_BRANCH="${CAIRNLORE_BRANCH:-main}"                        # hub long-lived branch
OPENCODE_DIR="${CAIRNLORE_OPENCODE_DIR:-$HOME/.config/opencode}"  # global opencode config
SKILLS_DIR="${CAIRNLORE_SKILLS_DIR:-$HOME/.agents/skills}"        # global skills

say()  { printf '  %s\n' "$*"; }
head() { printf '\n=== %s ===\n' "$*"; }

backup() {
  local t="$1"
  if [ -e "$t" ] && [ ! -L "$t" ]; then
    mv "$t" "$t.bak-$TS"
    say "backed up existing $t -> $t.bak-$TS"
  elif [ -L "$t" ]; then
    rm -f "$t"
  fi
}

[ -d "$PAYLOAD" ] || { echo "FATAL: payload/ not found next to install.sh"; exit 1; }

# --- 1. the knowledge hub (knowledge only; the engine never lands here) -------
head "1. Knowledge hub -> $HUB_HOME (branch $HUB_BRANCH)"
mkdir -p "$HUB_HOME/knowledge" "$HUB_HOME/journal" "$HUB_HOME/skills"
# Seed only INDEX.md and ESSENTIALS.md. AGENTS.md, OVERVIEW.md, USAGE.md and
# RESEARCH.md stay in $ENGINE_DIR so `git pull` updates them everywhere without
# ever touching a hub's knowledge. Nothing below copies them into the hub, so no
# message may point a reader at $HUB_HOME for one of them.
for f in INDEX.md ESSENTIALS.md; do
  if [ -f "$HUB_HOME/$f" ]; then
    say "kept existing $f"
  else
    cp "$PAYLOAD/framework/$f" "$HUB_HOME/$f"
    say "seeded $f"
  fi
done
[ -n "$(ls -A "$HUB_HOME/knowledge" 2>/dev/null)" ] || { cp -R "$PAYLOAD/framework/knowledge/." "$HUB_HOME/knowledge/"; say "seeded knowledge templates"; }
[ -n "$(ls -A "$HUB_HOME/journal" 2>/dev/null)" ]   || { cp -R "$PAYLOAD/framework/journal/." "$HUB_HOME/journal/"; say "seeded journal template"; }
say "engine NOT copied into the hub (lives at $ENGINE_DIR)"

# A git worktree has a .git FILE, not a directory. Testing for a directory here used to
# run `git init` inside a worktree and replace its link with a fresh standalone repo.
if ! git -C "$HUB_HOME" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$HUB_HOME" init -q
  git -C "$HUB_HOME" checkout -q -b "$HUB_BRANCH" 2>/dev/null || git -C "$HUB_HOME" checkout -q "$HUB_BRANCH"
  git -C "$HUB_HOME" add -A
  git -C "$HUB_HOME" -c user.email="ai@local" -c user.name="cairnlore" commit -q -m "init self-organizing knowledge hub"
  say "git-initialised hub on branch $HUB_BRANCH (add a remote + push when ready)"
else
  say "hub already a git repo; left as-is"
fi

# --- 2. global opencode rules ------------------------------------------------
head "2. Global opencode rules -> $OPENCODE_DIR"
backup "$OPENCODE_DIR/AGENTS.md"
# wire the hub path into the global rules
sed -e "s#__HUB_ROOT__#$HUB_HOME#g" -e "s#__ENGINE_DIR__#$ENGINE_DIR#g" \
    "$PAYLOAD/global/AGENTS.md" > "$OPENCODE_DIR/AGENTS.md"
say "wrote $OPENCODE_DIR/AGENTS.md (engine = $ENGINE_DIR, knowledge = $HUB_HOME)"
[ -f "$OPENCODE_DIR/opencode.jsonc" ] || { cp "$PAYLOAD/global/opencode.jsonc" "$OPENCODE_DIR/opencode.jsonc"; say "seeded opencode.jsonc"; }
mkdir -p "$OPENCODE_DIR/plugins"
for p in "$PAYLOAD"/global/plugins/*.js; do
  [ -e "$p" ] || continue
  backup "$OPENCODE_DIR/plugins/$(basename "$p")"
  cp "$p" "$OPENCODE_DIR/plugins/"
  say "installed global plugin: $(basename "$p")"
done

# --- 3. generic global skills ------------------------------------------------
head "3. Global skills -> $SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
for d in "$PAYLOAD"/skills/*/; do
  name="$(basename "$d")"
  backup "$SKILLS_DIR/$name"
  cp -R "$d" "$SKILLS_DIR/$name"
  say "installed skill: $name"
done
# surface the hub's own skills globally via a symlink (opencode native discovery)
ln -sfn "$ENGINE_DIR/skills" "$SKILLS_DIR/_cairnlore" 2>/dev/null && say "linked engine skills at $SKILLS_DIR/_cairnlore" || true
ln -sfn "$HUB_HOME/skills"   "$SKILLS_DIR/_hub"   2>/dev/null && say "linked hub skills at $SKILLS_DIR/_hub" || true

# --- done --------------------------------------------------------------------
head "Done"
cat <<EOF
  Engine:   $ENGINE_DIR  (pull-only: git -C ~/.cairnlore pull)
  Knowledge:$HUB_HOME  (branch $HUB_BRANCH)
  Rules:    $OPENCODE_DIR/AGENTS.md
  Skills:   $SKILLS_DIR

  Next:
    - Read $ENGINE_DIR/OVERVIEW.md - the whole framework on one page.
    - Open any project with opencode; it auto-reads the global AGENTS.md,
      which points every session at the hub engine + INDEX.
    - Give the hub a remote to enable R15 auto-push:
        git -C "$HUB_HOME" remote add origin <url> && git -C "$HUB_HOME" push -u origin $HUB_BRANCH
EOF
