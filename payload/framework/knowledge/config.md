# Config

> Self-maintained. When you discover a build, run, environment, version, or setup
> fact, append it here in the same turn (AGENTS.md R3). Cite `path:line` from disk.
> Load this file when a request is about building, running, environments, or versions.
> Every entry ends with `[verified YYYY-MM-DD]` or `[inferred]` (AGENTS.md R25).
> An `[inferred]` entry may not justify a change until someone checks it.

---

## Project

- **Name:** `<repo name>`
- **Language / runtime:** `<...>`  (source: `<path:line>`)
- **Build tool:** `<...>`  (source: `<path:line>`)
- **How to build:** `<command>`
- **How to run tests:** `<command>`

## Environments

| Env | How to select it | Notes |
|---|---|---|
| `<name>` | `<flag / var / file>` | `<...>` |

## Required environment variables / secrets

| Var | Purpose | Where it is read | Notes |
|---|---|---|---|
| `<NAME>` | `<...>` | `<path:line>` | never hardcode; not stored here |

## Setup gotchas

- `<one verified fact per line, with path:line where relevant>`
