# Conventions

> Self-maintained. When you learn a pattern, rule, domain fact, mapping, or naming
> convention, append it here in the same turn (AGENTS.md R3). Load this file before
> writing code so new work matches existing patterns (AGENTS.md R2).
> Every entry ends with `[verified YYYY-MM-DD]` or `[inferred]` (AGENTS.md R25).
> An `[inferred]` entry may not justify a change until someone checks it.

---

## Patterns to follow

> How this project does a recurring thing. One heading per pattern. Show the canonical
> example with a `path:line` so the agent copies the real convention, not a generic one.

### `<pattern name>`

- **When:** `<situation this applies to>`
- **Do:** `<the rule>`
- **Canonical example:** `<path:line>`

## Domain rules and mappings

> Business rules, decision tables, status mappings, enum meanings. The stuff an agent
> would otherwise guess wrong. Record the source (spec, ticket, wiki) next to each.

| Input | Expected | Rule / source |
|---|---|---|
| `<...>` | `<...>` | `<rule + where it came from>` |

## Naming and style

- `<verified convention per line - matches the codebase, not a style guide>`
