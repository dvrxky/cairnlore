---
name: jira-cli-readonly
description: Use this skill for Jira ticket interaction when the user wants to read/fetch/inspect data only: open a Jira URL, view issue details, list comments, fetch linked issues, search Jira with JQL, or retrieve self-related items (assigned/reported/watched) without modifying anything.
---

# Jira CLI Read-Only

Read-only Atlassian Jira skill using `acli` with strict non-modification policy.

## When to use this skill

Use this skill when user intent includes any of these signals:

- "I do not want to modify anything"
- "read-only" / "readonly"
- "just read" / "just fetch" / "inspect only"
- "do not update Jira"
- "read this Jira ticket" / "get ticket details"
- "show comments on this issue"
- "fetch linked tickets"
- "show my Jira issues" / "tickets assigned to me" / "reported by me"
- "inspect this Jira URL" / shares a `/browse/KEY-123` URL

Do not use this skill for Jira write/update actions.

## Common use cases (summary only - see reference for detailed patterns if needed)

1. **Find my comments (last 48h):** Example intent: "show my comments from the last 48 hours." Use two-step discovery (`updatedBy`) plus comment filtering (`author` + `created`). Read `references/use-cases-examples.md` paragraph **1** before running commands to apply the full correct flow and avoid invalid patterns.
2. **Find tickets assigned to me:** Example intent: "list my active assigned tickets." Use `assignee = currentUser()` and optionally exclude done statuses. Read `references/use-cases-examples.md` paragraph **2** before running commands to apply the correct scope and avoid reporter/assignee mix-ups.
3. **Get my sprint workload snapshot:** Example intent: "show my tickets in active sprint(s)." Use `assignee = currentUser()` plus `sprint in openSprints()` with priority-ordered output. Read `references/use-cases-examples.md` paragraph **9** before running commands to apply stable sprint filters.
4. **Prepare standup update:** Example intent: "what changed since yesterday in my scope?" Use a recent-update query over assignee/reporter scope and return concise deltas. Read `references/use-cases-examples.md` paragraph **10** before running commands to keep the update signal-focused.
5. **Inspect ticket dependencies quickly:** Example intent: "what is this ticket blocked by / linked to?" Use key-first `link list` then selective `view` on linked keys. Read `references/use-cases-examples.md` paragraph **11** before running commands to handle link direction and dedupe correctly.
6. **Generate a manual Jira update draft (read-only):** Example intent: "draft a short update I can paste into Jira." Read issue context with ACLI, combine with user-provided work notes, and return a 30-second paste-ready summary. Read `references/use-cases-examples.md` paragraph **12** before running commands to keep output concise and actionable.

## Output behavior (required)

When responding while this skill is active, always include exactly 3 ultra-short "also can do" examples at the end of the response.

- Keep each example readable in about 2 seconds (3-6 words).
- Keep examples action-oriented and read-only.
- Do not repeat the user's current request as an example.

Suggested format:

```text
Also can do:
- My active sprint tickets
- Recent comments on TEAM-123
- Quick dependency check
```

## Hard safety policy

Only run commands that are read-only against Jira data.

- Never run create/edit/delete/assign/transition/archive/unarchive/comment-create/comment-update/comment-delete/link-create/link-delete/attachment-delete/watcher-remove.
- Never run commands that submit new data (for example `acli feedback`).
- Never use Jira REST API endpoints directly (for example `curl`/`http` calls to `/rest/api/*`).
- Never run non-ACLI scripting fallbacks (`python`, `node`, custom parsers) to derive Jira answers when ACLI does not directly support the request.
- Never request, store, or use Jira API tokens in this skill.
- If a command is ambiguous or you are not 100% sure it is read-only, halt and ask the user first.
- If a task can be interpreted as read-only _or_ mutating, halt and ask for explicit permission.

If ACLI cannot retrieve requested data (for example issue changelog history), report the CLI limitation clearly and stop. Do not suggest REST API or token-based workarounds.

Known limitation:

- Jira issue history/changelog is not retrievable via current ACLI `jira workitem` commands.
- Jira REST API supports changelog/history retrieval, but this skill explicitly forbids REST API usage.
- Therefore, when users request assignment/history audit details, state that ACLI cannot provide it in this mode.
- ACLI/JQL does not provide a reliable single-query filter for "comments authored by current user in the last N hours" in this environment (for example `commentedBy`/`lastCommentedBy` may be unavailable, and `updatedBy(currentUser(), ...)` may not parse).
- Read-only ACLI workaround is supported: use `updatedBy("<email>", "-Nd")` to discover candidate issues, then inspect each issue's `comment` field and filter by `author` + `created` timestamp.

Mutating flag patterns to never use in this skill (disallowed):

- `--summary`, `--description`, `--description-file`
- `--assignee`, `--remove-assignee`
- `--type` (when used to change issue type)
- `--labels`, `--remove-labels`
- `--yes` on mutation-capable commands
- Any flag used with create/edit/transition/delete/assign/comment-write/link-write commands

## Authentication policy

Web SSO only:

```bash
acli jira auth login --web
```

Allowed authentication mode in this skill:

- ACLI OAuth/Web SSO (`acli jira auth login --web`) only.
- Do not use `JIRA_API_TOKEN`, basic auth with email/token, or any PAT/token-based auth flow.

Read-only-safe auth checks:

```bash
acli jira auth status
```

If unauthenticated, ask user to complete `acli jira auth login --web` before proceeding.

## Official docs

- Main docs: `https://developer.atlassian.com/cloud/acli/`
- Commands reference: `https://developer.atlassian.com/cloud/acli/reference/commands/`
- Jira commands: `https://developer.atlassian.com/cloud/acli/reference/commands/jira/`

## Allowed read-only commands

Use only commands in this list.

## Read-only quick reference

| Intent               | Read-only command                                                                                                                                              |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| View ticket          | `acli jira workitem view MYPROJECT-1455 --fields "summary,comment,status,assignee" --json`                                                                     |
| My open sprint items | `acli jira workitem search --jql "project = MYPROJECT AND assignee = currentUser() AND sprint in openSprints()" --fields "key,summary,status,priority" --json` |
| List comments        | `acli jira workitem comment list --key MYPROJECT-1455 --order +created --paginate --json`                                                                      |
| List linked tickets  | `acli jira workitem link list --key MYPROJECT-1455 --json`                                                                                                     |
| Project details      | `acli jira project view --key MYPROJECT --json`                                                                                                                |

### Auth status

```bash
acli jira auth status
```

### Projects

```bash
acli jira project list
acli jira project list --recent
acli jira project list --limit 100 --json
acli jira project list --paginate --json
acli jira project view --key TEAM
acli jira project view --key TEAM --json
```

### Boards and sprints

```bash
acli jira board search --project TEAM --type scrum --orderBy +name --limit 200 --json
acli jira board search --name "platform" --private --paginate --csv
acli jira board list-sprints --id 123 --state active,closed --paginate --json
acli jira sprint list-workitems --board 6 --sprint 42 --fields "key,summary,status,assignee,priority" --paginate --json
acli jira sprint list-workitems --board 6 --sprint 42 --jql "assignee = currentUser() ORDER BY updated DESC" --limit 200 --csv
```

### Dashboards and filters

```bash
acli jira dashboard search --owner user@example.com --name "team" --paginate --json
acli jira dashboard search --limit 50 --csv

acli jira filter list --my --json
acli jira filter list --favourite --json
acli jira filter search --owner user@example.com --name "report" --paginate --json
acli jira filter search --limit 200 --csv
```

### Work item search and view

```bash
acli jira workitem search --jql "project = TEAM ORDER BY updated DESC" --fields "key,summary,assignee,status,priority,updated" --paginate --json
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done" --limit 200 --csv
acli jira workitem search --filter 10001 --fields "key,summary,status" --json
acli jira workitem search --jql "project = TEAM" --count

acli jira workitem view TEAM-123 --json
acli jira workitem view TEAM-123 --fields "*navigable,-comment"
acli jira workitem view TEAM-123 --fields "summary,description,comment,issuelinks"
acli jira workitem view TEAM-123 --web
```

### Field allowlist pitfalls (`search --fields`)

`acli jira workitem search --fields` does not always accept every Jira field name.

- Start with known-safe defaults: `issuetype,key,assignee,priority,status,summary`.
- If `search --fields` fails with `field <name> is not allowed`, remove unsupported fields.
- Prefer `search` for key discovery, then `view` for richer per-issue fields.

Example intent: "search fails because a field is not allowed." Read `references/use-cases-examples.md` paragraph **7** before running commands to follow the required fallback sequence (`search` then `view`).

### Comments, links, attachments (read-only forms)

```bash
acli jira workitem comment list --key TEAM-123 --order +created --paginate --json
acli jira workitem comment list --key TEAM-123 --order -updated --limit 200 --csv

acli jira workitem link list --key TEAM-123 --json
acli jira workitem link type

acli jira workitem attachment list --key TEAM-123 --json
acli jira workitem comment visibility --key TEAM-123
```

## URL-driven read-only workflows (summary)

- **Full issue from URL:** Example intent: "open this Jira URL and summarize the ticket." Read `references/use-cases-examples.md` paragraph **3** before running commands to apply key extraction and normalization correctly.
- **Linked issues from URL:** Example intent: "from this ticket URL, list linked tickets with status/assignee." Read `references/use-cases-examples.md` paragraph **4** before running commands to handle link payload variations safely.
- **Comments from URL:** Example intent: "show all comments for this Jira URL." Read `references/use-cases-examples.md` paragraph **5** before running commands to use the correct comment retrieval path.
- **Markdown dossier from URL:** Example intent: "create a read-only markdown report for this ticket URL." Read `references/use-cases-examples.md` paragraph **6** before running commands to produce the complete report artifact.

## Read-only "my tickets" patterns (summary)

- **Assigned tickets (default):** Example intent: "what tickets are assigned to me?" Use `assignee = currentUser()`; add `statusCategory != Done` for active-only. Read `references/use-cases-examples.md` paragraph **2** before running commands to keep assignment scope correct.
- **Broader self-scoped discovery:** Example intent: "show tickets reported by me" or "where I am mentioned." Read `references/use-cases-examples.md` paragraph **8** before running commands to choose the right non-assignment pattern.

## Key-first targeting rule

- If the user provides a concrete issue key (for example `MYPROJECT-1455`) or a Jira `/browse/` URL, use key-based read commands first.
- Use JQL for discovery/list/filter scenarios or when no concrete key is provided.

## JQL patterns reference

Detailed operator/function/date patterns and advanced examples are maintained in `references/jql-patterns.md`.

## Edge cases and guardrails

- URL is not canonical `/browse/KEY-123`: normalize first or ask user for canonical issue URL.
- URL contains trailing punctuation from chat: trim `)`, `]`, `.`, `,` before parsing.
- Key appears lowercase (`team-123`): normalize to uppercase.
- Multiple URLs in one message: run separate read pipelines and label each output.
- Partial data visibility is expected with Jira permissions; explicitly report partial visibility.
- For large responses, write to files (`.json`/`.md`) to avoid terminal truncation.

## Ambiguity rule (must ask)

Ask user before running if any command/request could be interpreted as mutating.

Examples that require confirmation:

- User says "clean up tickets" (could imply transitions/deletes).
- User says "prepare these issues" without specifying read-only output.
- A command candidate is unknown or undocumented in this skill's allowlist.

Recommended clarification question:

"I can continue in strict read-only mode (no Jira modifications). I will only run list/search/view commands. Confirm?"

## Never-allowed commands in this skill

```text
jira project create|update|archive|restore|delete
jira field create|delete|cancel-delete
jira filter add-favourite|change-owner
jira workitem create|create-bulk|edit|assign|transition|clone|archive|unarchive|delete
jira workitem comment create|update|delete
jira workitem link create|delete
jira workitem attachment delete
jira workitem watcher remove
feedback
```

## Never-allowed integration patterns in this skill

```text
curl|http|wget calls to *.atlassian.net/rest/api/*
Any workflow requiring JIRA_API_TOKEN or email:token auth
Any suggestion to switch from ACLI to direct REST for read workflows
```
