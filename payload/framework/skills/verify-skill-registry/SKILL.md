---
name: verify-skill-registry
description: Audit the hub's skills for duplicates, registry drift, and malformed frontmatter; and run a near-duplicate check BEFORE authoring a new skill. Use when the user says "add a skill", "audit the skills", "check for duplicate skills", "is there already a skill for X", "verify the skill registry", or before creating any new skills/<slug>/SKILL.md folder.
---

# Skill: Verify Skill Registry

> The dedup gate and integrity audit for `skills/`. Run the "pre-create dedup check"
> (section A) BEFORE authoring any new skill (AGENTS.md section 8 step 1). Run the
> "full audit" (section B) on demand to catch registry drift. Auditing history beyond
> this is `git log` on `HUB_BRANCH` (see section C).

- **triggers:** "add a skill", "new skill", "audit the skills", "check for duplicate skills", "is there a skill for", "verify the skill registry", "which skills exist"
- **preconditions:** run from `HUB_ROOT` (the dir holding `INDEX.md`, `README.md`, `skills/`)

## Steps

### A. Pre-create dedup check (run before authoring a new skill)

A name-substring grep is not enough: two skills can overlap with no shared word. Check
name, description, AND triggers.

1. List existing skill slugs:
   ```bash
   ls skills | grep -v '^_template$'
   ```
2. Full-text search the intent keywords across every skill's `description` + `triggers`
   and the INDEX skills table. Pass 2-4 keywords from the proposed workflow:
   ```bash
   KW='revert|unmerge|rollback'          # <- proposed-workflow keywords, pipe-separated
   grep -rniE "$KW" skills/*/SKILL.md INDEX.md
   ```
3. Read every SKILL.md that matched. Decide consciously:
   - **Overlap = same workflow** -> STOP. Do NOT create a new folder. Append/refine the
     existing skill (AGENTS.md R4). Tell the user which skill covers it.
   - **Overlap = adjacent but distinct** -> proceed to create, and add a one-line
     "Related skills" cross-reference in both SKILL.md files so future searches connect them.
   - **No overlap** -> proceed to create.
4. Only after this check, follow AGENTS.md section 8 steps 2-5 to author + register.

### B. Full registry audit (run on demand)

1. Skills on disk vs INDEX rows (both directions - orphan folders and stale rows):
   ```bash
   comm -3 \
     <(ls skills | grep -v '^_template$' | sort) \
     <(grep -oE 'skills/[a-z0-9-]+/SKILL\.md' INDEX.md | sed 's#skills/##;s#/SKILL.md##' | sort -u)
   ```
   Any output = drift. Left column = folder with no INDEX row (register it). Right column
   = INDEX row with no folder (remove the stale row or restore the folder).
2. Every skill folder actually contains a `SKILL.md`:
   ```bash
   for d in skills/*/; do
     [ -f "$d/SKILL.md" ] || echo "MISSING SKILL.md: $d"
   done
   ```
   Any output = a folder that discovery will silently skip.
3. Frontmatter validity - every skill has a `name:` matching its folder, and a `description:`:
   ```bash
   for d in skills/*/; do
     s="$d""SKILL.md"; slug="${d#skills/}"; slug="${slug%/}"
     [ "$slug" = "_template" ] && continue
     [ -f "$s" ] || continue
     name=$(grep -m1 '^name:' "$s" | sed 's/^name:[[:space:]]*//')
     grep -q '^description:' "$s" || echo "NO description: $slug"
     [ "$name" = "$slug" ] || echo "NAME MISMATCH: folder=$slug name=$name"
   done
   ```
4. Report only the failing lines. If everything passes, say so in one line (AGENTS.md R8).

### C. Historical audit (who added/changed a skill, when)

The framework keeps no separate skill changelog. Git history on `HUB_BRANCH` is the audit
trail:
```bash
git log --follow --oneline -- skills/<slug>/SKILL.md      # one skill's history
git log --oneline --name-only -- 'skills/*/SKILL.md'      # all skill add/change events
```

## Validation

- Section A: the proposed slug does not duplicate an existing workflow; near-duplicates
  were read and consciously classified.
- Section B: all three `comm`/loop checks produce no unexpected output; frontmatter loop
  prints nothing.

## Guardrails

- **AGENTS.md R4:** never create a second skill folder for a workflow that already has one.
- **AGENTS.md R9:** if reality diverges from these steps, update this file first.
- **AGENTS.md R13:** this operates only on the hub; it never touches a code repo.

## Example prompts

- "is there already a skill for reverting a PR?"
- "audit the skill registry"
- "before you add that skill, check for duplicates"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
