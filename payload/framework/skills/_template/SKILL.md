---
name: <verb-noun>
description: <One or two sentences describing when opencode should load this skill. Include concrete trigger phrases the user might say. This description is how opencode's native skill discovery matches user requests to this skill.>
---

# Skill: <Verb Noun>

> A skill is a named, repeatable workflow the agent runs on request. Copy this template
> folder to `skills/<verb-noun>/`, rename to `SKILL.md`, fill every field, and register it
> in `INDEX.md` (skills table). See AGENTS.md section 8 for the build rules.

- **triggers:** `<phrases / keywords that should load and run this, e.g. "release notes", "cut a release">`
- **preconditions:** `<what must be true before running - env vars, branch state, tools>`

## Steps

1. `<concrete, idempotent step>`
2. `<...>`  (cite `path:line` for anything code-specific)
3. `<...>`

## Validation

- `<how to confirm the workflow succeeded>`

## Example prompts

- `<"do the thing" phrasings a user might say>`

---

> If reality diverges from these steps, STOP: update this file first, then execute
> (AGENTS.md R9). This file is the source of truth for the workflow. Never commit
> code-repo changes; the hub auto-commits and pushes (R15).
