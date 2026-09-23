---
name: bootstrap-project
description: Seed a new project's subtree in the hub the first time the agent works on it. Creates knowledge/projects/<project>/{config,conventions,known-issues}.md from templates, fills config from the project's main clone (build tool, versions, entry points), and adds the project to the INDEX component map. Use when the user says "bootstrap project X", "add project X to the hub", "seed knowledge for X", or when working on a project that has no HUB_ROOT/knowledge/projects/X/ yet.
---

# Skill: Bootstrap a project into the hub

> Formalizes AGENTS.md section 7. Every project the agent works on gets a subtree in the
> hub: three template knowledge files, an INDEX row, and (if the project has enough
> traffic) a per-project journal directory. No `.ai/` folder inside the code repo (R13),
> no `feature/docs` branch.

- **triggers:** bootstrap project, add project to the hub, seed knowledge for, onboard project into the hub, no knowledge for this project yet
- **preconditions:**
  - The project's main code clone is checked out somewhere on disk and the user tells
    you (or you can verify) its absolute path.
  - No `HUB_ROOT/knowledge/projects/<project>/` directory exists yet. If it does, refuse
    - the project is already bootstrapped; use the R3 loop to extend it, not this skill.

## Steps

1. **Resolve names**:
   - `<project>` = the project's slug (lowercase, hyphenated). Usually the code repo's
     folder name.
   - `<code-repo-path>` = absolute path to the project's main clone.
   - Confirm both with the user (R2) if there is any ambiguity.

2. **Create the subtree**:
   ```
   HUB_ROOT/knowledge/projects/<project>/
     config.md
     conventions.md
     known-issues.md
     README.md
   ```
   Use the framework's own templates as scaffolds:
   - `HUB_ROOT/framework/knowledge/config.md` -> `<project>/config.md`
   - `HUB_ROOT/framework/knowledge/conventions.md` -> `<project>/conventions.md`
   - `HUB_ROOT/framework/knowledge/known-issues.md` -> `<project>/known-issues.md`
   Add a header banner at the top of each: "Project `<project>` - `<file>`. Source of
   truth for `<project>` facts of this kind. Grows through R3."

3. **Fill `<project>/config.md`** from what you can verify in the code repo, cited from
   disk this session (R6):
   - Build tool + language + versions (`build.gradle`, `pom.xml`, `package.json`,
     `Cargo.toml`, etc.).
   - How to build and run locally (from `README.md`, `Makefile`, `.tool-versions`).
   - Env vars, config file locations.
   - Entry-point paths (`Main.java:line`, `main.py:line`, `index.ts:line`).
   Every claim carries `path:line`.

4. **Leave `<project>/conventions.md` and `<project>/known-issues.md` as headed
   templates.** These grow through the R3 loop; do not pre-fill them.

5. **Write `<project>/README.md`** (short, ~15 lines) covering:
   - One-line project purpose.
   - Code repo path (main clone).
   - Bullet list of the knowledge files in this subtree.
   - Journal home: `HUB_ROOT/journal/projects/<project>/` (create empty dir).

6. **Add the project to `HUB_ROOT/INDEX.md`**:
   - Per-project knowledge table: one row with focus + trigger keywords.
   - Component map: one row with what it is, code-repo path, knowledge path, fallback.

7. **Create the per-project journal directory** (empty) at
   `HUB_ROOT/journal/projects/<project>/`. Copy `HUB_ROOT/journal/_template.md` there is
   NOT required - journals are opened by `start-task` from the hub-root template.

8. **Do NOT touch the code repo.** No `.ai/`, no branch changes, no commits (R13).

9. **Commit and push the hub** (R15), echoing the commit message in the response.

## Validation

- `HUB_ROOT/knowledge/projects/<project>/` exists with `config.md`, `conventions.md`,
  `known-issues.md`, `README.md`.
- `config.md` has real facts cited `path:line` from the code repo (not placeholders).
- `conventions.md` and `known-issues.md` are template stubs with a header explaining
  what belongs there.
- `HUB_ROOT/INDEX.md` has the project registered in the per-project knowledge table AND
  the component map.
- `HUB_ROOT/journal/projects/<project>/` exists (empty).
- No file was created inside the code repo.

## Guardrails

- Refuse if a subtree for `<project>` already exists. Extending existing knowledge is
  the R3 loop's job.
- Do not create `.ai/` in the code repo (R13).
- Do not invent config facts. If you cannot verify from disk this session, leave a
  `TODO(bootstrap): verify <fact>` line in the template instead of guessing.

## Example prompts

- "bootstrap project <project-a> (code at ~/git/<hub-repo>/<project-a>)"
- "add project futures-consumer to the hub"
- "seed knowledge for the new liability-guard-monitor spike"
- "there's no hub subtree for trading-alerts yet - onboard it"

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). Never commit or write anything inside a project code repo (R13,
> section 6).
