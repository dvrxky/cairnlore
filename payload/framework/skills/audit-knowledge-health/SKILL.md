---
name: audit-knowledge-health
description: Measure the health of the hub's knowledge before curating it - which knowledge files everything points at, which nothing points at, which ESSENTIALS items have never helped, which pointers are broken, and how much unverified claim debt has built up. Use when the user says "audit the knowledge", "is my hub healthy", "what knowledge is dead", "which ESSENTIALS should I demote", "check for orphaned knowledge", or when ESSENTIALS passes its soft target and something has to be demoted.
---

# Skill: Audit Knowledge Health

> R19 and R24 require items to be earned and demoted on evidence. This skill produces the
> evidence. It measures the hub, it does not rewrite it: every delta is proposed, then
> applied only on confirmation, one item at a time (R23).

- **triggers:** `"audit the knowledge"`, `"hub health"`, `"what knowledge is dead"`, `"which ESSENTIALS should I demote"`, `"orphaned knowledge"`, ESSENTIALS passing its soft target of 40 items
- **preconditions:** `CAIRNLORE_HOME` points at the hub; `CAIRNLORE_ENGINE` points at the engine's `payload/framework`; `rg` available

## Steps

1. Resolve both roots. Pointers resolve against different roots: `knowledge/*` lives in
   the hub, `AGENTS.md` lives in the engine. `CAIRNLORE_HOME` and `CAIRNLORE_ENGINE` are set by
   the installer but are not exported into every shell, so fall back to the installed
   defaults and to the paths named in the hub's `INDEX.md` Operating model block.

   ```sh
   HUB="${CAIRNLORE_HOME:-$HOME/cairnlore-hub}"
   ENG="${CAIRNLORE_ENGINE:-$HOME/.cairnlore/payload/framework}"
   [ -f "$HUB/INDEX.md" ] || { echo "no hub at $HUB: set CAIRNLORE_HOME"; exit 1; }
   [ -f "$ENG/AGENTS.md" ] || { echo "no engine at $ENG: set CAIRNLORE_ENGINE"; exit 1; }
   cd "$HUB"
   ```

2. Rank knowledge files by inbound references. The top of this list is what the hub
   actually runs on; the bottom is a demotion shortlist.

   Match on the basename when it is unique in the tree, and on the last two path segments
   when it is not. Basename-only counting makes every `README.md` reference every other
   one; path-only counting misses the bare-filename references that most cross-references
   actually use.

   ```sh
   find knowledge -name '*.md' | xargs -n1 basename | sort | uniq -d > /tmp/dupnames.txt
   find knowledge -name '*.md' -print0 | while IFS= read -r -d '' f; do
     n=$(basename "$f")
     if grep -qxF "$n" /tmp/dupnames.txt; then
       key=$(echo "$f" | rev | cut -d/ -f1,2 | rev)
     else
       key="$n"
     fi
     c=$(rg -l --fixed-strings "$key" . --glob "!$f" 2>/dev/null | wc -l | tr -d ' ')
     echo "$c $f"
   done | sort -rn > /tmp/kref.txt
   head -10 /tmp/kref.txt
   ```

   Exclude dated archives and convention-reachable files before reading the orphan list.
   A hub that keeps `DD-MM-YYYY_SOT.md` snapshots beside a `SOT-current.md` symlink has no
   inbound reference to the dated file by design. The per-project trio defined in AGENTS.md
   section 7 is reached through the project subtree, never listed file by file in `INDEX.md`,
   so a zero score there means nobody name-dropped it, not that it is unreachable. Counting
   either kind drowns the real findings.

   ```sh
   awk '$1==0 {print $2}' /tmp/kref.txt \
     | rg -v '[0-9]{2}-[0-9]{2}-[0-9]{4}_SOT\.md$' \
     | rg -v '/(specs|adr)/' \
     | rg -v '^knowledge/projects/.*/(config|conventions|known-issues)\.md$' > /tmp/orphans.txt
   wc -l < /tmp/orphans.txt
   ```

   The trio becomes a finding only when the project's whole subtree is missing from the
   `INDEX.md` component map, which is what step 3 checks.

   A file with a high count that is absent from `ESSENTIALS.md` is a promotion candidate:
   everything points at it, so its headline rule belongs in the playbook.
   A file left in `/tmp/orphans.txt` is a real orphan: nothing references it and nothing
   will load it.

3. Find broken pointers. An ESSENTIALS item whose detail has moved is worse than no item,
   because it sends the next session somewhere that no longer exists.

   ```sh
   rg -o '\-> `?([A-Za-z0-9_./-]+\.md)' ESSENTIALS.md -r '$1' | sort -u | while read -r p; do
     [ -e "$HUB/$p" ] || [ -e "$ENG/$p" ] || echo "BROKEN POINTER: $p"
   done
   rg -o '`(knowledge/[A-Za-z0-9_./-]+\.md)`' INDEX.md -r '$1' | sort -u | while read -r p; do
     [ -e "$HUB/$p" ] || echo "INDEX ROW POINTS AT MISSING FILE: $p"
   done
   find knowledge/projects -mindepth 1 -maxdepth 2 -type d | while read -r d; do
     [ -n "$(find "$d" -maxdepth 1 -name '*.md' -print -quit)" ] || continue
     rg -q --fixed-strings "${d#knowledge/projects/}" INDEX.md \
       || echo "PROJECT SUBTREE MISSING FROM INDEX: $d"
   done
   ```

4. Grade the playbook against its own rules (R19).

   ```sh
   echo "items: $(rg -c '^- .\[E-' ESSENTIALS.md) (soft target 40)"
   rg -n 'm:[2-9]' ESSENTIALS.md   # R19: delete or rewrite, never keep
   rg -n '\(h:0 m:0\)' ESSENTIALS.md   # never fired: demote first if over target
   ```

5. Measure unverified claim debt (R25). Inferred claims are allowed to exist, but they may
   not accumulate silently, and they may never justify a change.

   ```sh
   rg -c '\[inferred\]' knowledge/ 2>/dev/null | sort -t: -k2 -rn
   cutoff=$(date -v-90d +%Y-%m-%d 2>/dev/null || date -d '90 days ago' +%Y-%m-%d)
   rg -o '\[verified ([0-9]{4}-[0-9]{2}-[0-9]{2})\]' -r '$1' knowledge/ \
     | awk -F: -v c="$cutoff" '$2 < c {print "STALE " $2 "  " $1}' | sort -k2 | head -10
   ```

   Flag every `[inferred]` entry in a file whose subject the current session touched, and
   every `[verified]` date older than 90 days in `config.md` or any infrastructure file,
   where drift is silent and expensive.

6. Report, ranked, worst first. Group as: broken pointers, playbook items violating R19,
   orphans, promotion candidates, provenance debt. Cap the visible list at the 5 items per
   group that matter most; hold the rest for follow-up.

7. Apply deltas one at a time, each on explicit confirmation (R23). Promote a headline rule
   into `ESSENTIALS.md` with the next free id and `(h:0 m:0)`. Demote by deleting the line
   only, never by merging two items into a vaguer one. Repair a broken pointer in place.
   Delete an orphan only after confirming it is not a spec or ADR, which are immutable.

8. Commit and push the hub (R15).

## Validation

- Every pointer in `ESSENTIALS.md` and every `knowledge/` row in `INDEX.md` resolves.
- No large group of files shares one identical high score and one basename, which is the
  signature of basename-collision counting. Isolated ties at low scores are normal and
  are not a finding.
- Every reported orphan has been opened and confirmed to be none of: a dated archive, an
  immutable spec or ADR, or a per-project file reachable through AGENTS.md section 7.
- No item carries `m:2` or higher.
- Item count is at or under 40, or the overage is a deliberate, stated choice.
- Every orphan is either referenced from `INDEX.md`, deleted, or recorded as deliberate.
- Re-running the skill reports no finding that the previous run claimed to have fixed.

## Example prompts

- `"audit the knowledge"`
- `"hub health check"`
- `"which knowledge files is nothing pointing at?"`
- `"ESSENTIALS is over 40, what should I demote?"`
- `"how much of knowledge/ is still unverified?"`

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
