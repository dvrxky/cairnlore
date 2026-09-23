# Research and design provenance

Why this framework is shaped the way it is, and what alternative designs were considered
and rejected. Keep this current when an engine rule (R1-R17), the loop, or the git model
changes.

## What this framework is (and is not)

This is a **self-organizing knowledge / memory hub** for an AI coding agent working across
many services. Its job is to capture durable facts, source-of-truth specs, per-task
journals, and repeatable skills, and to keep them cited from disk and deduplicated. It is
deliberately **markdown-only**: no scripts to run, no build/test/deploy, no execution
engine. The agent reads code directly from each project's clone for `path:line` citations
(R6) and writes knowledge only into this hub (R13).

It is NOT an execution harness. It does not compile, test, scan, or gate code. Those
belong to the project's own CI and to the human who owns commit -> build -> deploy.

## Core design choices (rationale)

| Choice | Why |
|---|---|
| Progressive disclosure: read only `AGENTS.md` + `INDEX.md` at start, load the rest on trigger | Cheap startup, full depth on demand. Avoids context bloat that degrades agent performance. |
| Self-organizing loop (R3): record a discovery in the same turn you make it | Stops future sessions repeating dead ends; the knowledge files ARE the memory. |
| Cite from disk, never memory (R6) | Prevents fabricated `path:line` claims and stale-summary drift. |
| One file per concern, split at ~500 lines (R4, section 5) | Keeps knowledge scannable; an unscannable file goes unread. |
| Centralized hub, no `.ai/` folders or `feature/docs` branches in code repos (R13) | One home for knowledge; no framework artefacts polluting product repos. |
| Hub auto-commits and pushes; code repos never (R15) | The hub is memory and must persist automatically; product code stays under human control. |
| Agent-agnostic single entry file (`AGENTS.md`), symlinked for other agents, never copied | One source of truth; no vendor-specific duplication (violates R4). |

## Ideas adopted from ArchDeterminismAI (2026 spec-driven framework)

Reviewed `~/DOCS/ArchDeterminismAI` (a spec-kit-derived, gate-enforced,
TDD/verification framework). Most of it targets a different problem (forcing one feature
through specify -> plan -> tasks -> TDD -> gates -> review) and would conflict with this
hub's no-execution, markdown-only model. Four ideas were compatible and folded in:

| Adopted | Landed as | Why it fit |
|---|---|---|
| Fresh-context adversarial review; implementer does not grade its own work; nits are out of scope | `skills/adversarial-review/SKILL.md` | Reinforces R12; turns a principle into a runnable workflow. |
| Three-strike anti-loop then escalate; never repeat the same failing action | Engine rule **R16** | We had R5 (check known-issues first) but no explicit anti-loop / escalation rule. |
| Honesty over agreement; disagree when evidence contradicts | Engine rule **R17** | Was only in the personal global rules; now stated once in the hub engine. |
| A provenance / rationale document | this file | We had no record of why the rules exist or what was rejected. |

## What was explicitly rejected (and why)

| Rejected from ArchDeterminismAI | Why not |
|---|---|
| The `.specify/` seven-phase spec-kit loop, per-feature `specs/NNN/` folders | This hub is a memory store, not a feature-execution engine. The loop presumes the framework drives implementation; ours does not. |
| Deterministic FSM (`core/fsm.py`), event log, plan DAG, `orchestrator/loop.py` | Code machinery for an execution harness we do not run. Adds maintenance with no fit to a markdown knowledge hub. |
| `quality/gates.yaml` + `run-gate.sh`: lint / type / test / coverage / SAST / SCA / mutation | These RUN builds, tests, and scans. The agent is explicitly forbidden from build / deploy / CI (R6 job boundary, global rules). Gating belongs to the project's CI and the human. |
| `.agent/hooks/` (pre-edit, post-edit, stop) auto-format / auto-run gates | Same reason: deterministic execution and formatting of product code is out of scope for a knowledge hub. |
| MCP `mcp.json`, sandbox / seccomp / egress allow-lists | Infrastructure and tool-permission concerns owned by the environment, not by this hub's content model. |
| `tdd-cycle`, `brownfield-onboarding` skills | Tightly coupled to the spec-kit workflow we did not adopt. |
| A separate `constitution.md` as supreme law | Redundant: `AGENTS.md` (R1-R17) already IS the supreme, agent-first authority here. A second authority file would violate one-file-per-concern (R4). |

## Operating assumption

The human owns commit -> build -> deploy for all product code. This framework's job ends
at: knowledge on disk, cited, deduplicated, and (for the hub only) committed and pushed.
