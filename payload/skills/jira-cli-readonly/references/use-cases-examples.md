## 1) Find my Jira comments in the last 48 hours (ACLI-only workaround)

When Jira comment-author JQL fields are unavailable in your environment, use an ACLI-only two-step discovery pattern: first identify candidate issues updated by the user over the same broad period, then inspect issue comments and retain only comments authored by that user and created inside the last 48 hours.

Correct example A:

```bash
# Step 1: discover candidate issues (email works where currentUser() may fail)
acli jira workitem search --jql "issuekey in updatedBy(\"you@example.com\", \"-2d\") ORDER BY updated DESC" --fields "key,summary,status" --paginate --json

# Step 2: inspect comments on each returned key
acli jira workitem view ART-28 --fields "comment" --json
```

Correct example B:

```bash
# Narrow scope to a single project, still read-only
acli jira workitem search --jql "project = PROJ AND issuekey in updatedBy(\"you@example.com\", \"-2d\") ORDER BY updated DESC" --fields "key,summary,status" --paginate --json

# Read all comments for candidate issue and manually filter by author + created timestamp
acli jira workitem view ART-28 --fields "comment" --json
```

Wrong example A (obvious but invalid in many environments):

```bash
# Wrong: field may not exist in this Jira environment
acli jira workitem search --jql "commentedBy = currentUser() AND updated >= -2d" --fields "key,summary,status" --json
```

Why wrong: `commentedBy` is not guaranteed to exist/resolve in ACLI/JQL for all Jira tenants.

Wrong example B (obvious but not allowed by this skill):

```bash
# Wrong: direct Jira REST call is forbidden in this read-only ACLI skill
curl -s "https://<site>.atlassian.net/rest/api/3/search?jql=updated>=-2d" \
  -H "Authorization: Bearer <token>"
```

Why wrong: this skill allows ACLI OAuth/web auth only; REST/token workflows are explicitly disallowed.

## 2) Find tickets assigned to me

Use `assignee = currentUser()` as the baseline JQL. Add `statusCategory != Done` when the user asks for active tickets only.

Correct example:

```bash
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC" --fields "key,summary,status,priority" --paginate --json
```

Wrong example (obvious but incorrect scope):

```bash
# Wrong: returns tickets reported by me, not assigned to me
acli jira workitem search --jql "reporter = currentUser() ORDER BY updated DESC" --fields "key,summary,status" --paginate --json
```

Why wrong: `reporter` answers a different question than `assignee`.

## 3) Read a Jira URL -> full details

When a user provides a Jira browse URL, extract and normalize the key first, then run a key-based `view` call.

Correct example:

```bash
JIRA_URL="https://your-domain.atlassian.net/browse/TEAM-123"
KEY="$(echo "$JIRA_URL" | sed -E 's#^.*/browse/([A-Za-z][A-Za-z0-9_]*-[0-9]+).*$#\1#' | tr '[:lower:]' '[:upper:]')"
acli jira workitem view "$KEY" --fields "summary,description,status,assignee,priority,comment,issuelinks" --json
```

Wrong example:

```bash
# Wrong: skips normalization and may fail on lowercase keys or trailing punctuation
acli jira workitem view "team-123)" --fields "summary,status" --json
```

Why wrong: browse URLs and chat text may include lowercase keys or trailing punctuation; normalize key first.

## 4) Read a Jira URL -> linked tickets -> fetch each linked ticket

Use `link list` for relationship discovery, then fetch each linked issue with a focused `view` field set.

Correct example:

```bash
JIRA_URL="https://your-domain.atlassian.net/browse/TEAM-123"
KEY="$(echo "$JIRA_URL" | sed -E 's#^.*/browse/([A-Za-z][A-Za-z0-9_]*-[0-9]+).*$#\1#' | tr '[:lower:]' '[:upper:]')"

acli jira workitem link list --key "$KEY" --json \
  | jq -r '.results[]?.key // .results[]?.outwardIssue?.key // .results[]?.inwardIssue?.key' \
  | sed '/^$/d' | sort -u \
  | while read -r linked; do
      acli jira workitem view "$linked" --fields "summary,status,assignee,priority,updated" --json
    done
```

Wrong example:

```bash
# Wrong: assumes keys from link output without null checks or dedupe
acli jira workitem link list --key TEAM-123 --json | jq -r '.results[].key' | while read -r linked; do acli jira workitem view "$linked" --json; done
```

Why wrong: link payloads differ by link direction; null-safe extraction and dedupe are needed.

## 5) Read a Jira URL -> all comments

Use key extraction + `comment list` for complete comment history in stable order.

Correct example:

```bash
JIRA_URL="https://your-domain.atlassian.net/browse/TEAM-123"
KEY="$(echo "$JIRA_URL" | sed -E 's#^.*/browse/([A-Za-z][A-Za-z0-9_]*-[0-9]+).*$#\1#' | tr '[:lower:]' '[:upper:]')"
acli jira workitem comment list --key "$KEY" --order +created --paginate --json
```

Wrong example:

```bash
# Wrong: uses workitem view comment field when explicit comment list is requested
acli jira workitem view TEAM-123 --fields "comment" --json
```

Why wrong: `view --fields comment` can work, but `comment list` is the clearer command for full ordered comment retrieval.

## 6) Build a read-only markdown dossier from a Jira URL

When users ask for a report artifact, collect issue details, links, and comments into one markdown file.

Correct example:

````bash
JIRA_URL="https://your-domain.atlassian.net/browse/TEAM-123"
KEY="$(echo "$JIRA_URL" | sed -E 's#^.*/browse/([A-Za-z][A-Za-z0-9_]*-[0-9]+).*$#\1#' | tr '[:lower:]' '[:upper:]')"
STAMP="$(date +%Y%m%d-%H%M)"
OUT="jira-readonly-${KEY}-${STAMP}.md"

{
  echo "# Jira Read-Only Report: $KEY"
  echo
  echo "## Source URL"
  echo "$JIRA_URL"
  echo
  echo "## Issue Details"
  echo '```json'
  acli jira workitem view "$KEY" --fields "summary,description,status,assignee,priority,comment,issuelinks" --json
  echo '```'
  echo
  echo "## Linked Issues"
  echo '```json'
  acli jira workitem link list --key "$KEY" --json
  echo '```'
  echo
  echo "## Comments"
  echo '```json'
  acli jira workitem comment list --key "$KEY" --order +created --paginate --json
  echo '```'
} > "$OUT"
````

Wrong example:

```bash
# Wrong: combines ACLI with direct REST/token usage
curl -s "https://<site>.atlassian.net/rest/api/3/issue/TEAM-123" -H "Authorization: Bearer <token>" > jira.md
```

Why wrong: this skill forbids Jira REST and token-based auth workflows.

## 7) Handle `search --fields` allowlist failures

If `acli jira workitem search --fields` rejects a field, simplify the search and switch to per-issue `view` for rich fields.

Correct example:

```bash
# Step 1: search with stable fields
acli jira workitem search --jql "reporter = currentUser() ORDER BY created DESC" --fields "key,summary,status" --limit 300 --json

# Step 2: enrich a specific issue with view
acli jira workitem view MYPROJECT-1455 --fields "key,summary,status,created,updated,reporter,assignee" --json
```

Correct example (verification):

```bash
acli jira workitem search --jql "project = TEAM" --fields "issuetype,key,assignee,priority,status,summary" --limit 50 --json
```

Wrong example:

```bash
# Wrong: keeps retrying unsupported fields in search
acli jira workitem search --jql "project = TEAM" --fields "key,summary,comment,description,created,updated" --json
```

Why wrong: `search --fields` can reject non-allowlisted fields; use `view` for richer details.

## 8) Discover "my tickets" beyond assignment

Use this only when user intent is broader than "assigned to me" (for example, reported-by-me or mention-style discovery).

Correct example A (reported by me):

```bash
acli jira workitem search --jql "reporter = currentUser() ORDER BY created DESC" --fields "key,summary,status" --limit 300 --json
```

Correct example B (mention-style broad text search):

```bash
acli jira workitem search --jql "text ~ currentUser() ORDER BY updated DESC" --limit 200 --json
```

Wrong example:

```bash
# Wrong: uses reporter query to answer "assigned to me"
acli jira workitem search --jql "reporter = currentUser()" --fields "key,summary,status" --json
```

Why wrong: assigned and reported are separate scopes and should not be conflated.

## 9) Get my sprint workload snapshot

Use active sprint scope with current-user assignment to return what the user likely needs for planning and balancing work.

Correct example:

```bash
acli jira workitem search --jql "assignee = currentUser() AND sprint in openSprints() AND statusCategory != Done ORDER BY priority DESC, updated DESC" --fields "key,summary,status,priority" --paginate --json
```

Wrong example:

```bash
# Wrong: uses project-wide sprint scope and drops assignee constraint
acli jira workitem search --jql "sprint in openSprints() ORDER BY priority DESC" --fields "key,summary,status,priority" --paginate --json
```

Why wrong: it returns team-wide sprint work, not the user's workload snapshot.

## 10) Prepare standup update

Collect only recent changes in the user's scope (assignee or reporter), then summarize by what changed and what is next.

Correct example:

```bash
acli jira workitem search --jql "(assignee = currentUser() OR reporter = currentUser()) AND updated >= -1d ORDER BY updated DESC" --fields "key,summary,status,updated,priority" --paginate --json
```

Recommended response shape (30 seconds):

- Yesterday: 1-3 bullets of completed/progress items.
- Today: 1-3 bullets of planned work.
- Risks/Blocks: one line, `None` if clear.

Wrong example:

```bash
# Wrong: broad query creates noisy, low-signal standup output
acli jira workitem search --jql "project = TEAM ORDER BY updated DESC" --fields "key,summary,status,updated" --paginate --json
```

Why wrong: it ignores user scope and usually produces standup noise.

## 11) Inspect ticket dependencies quickly

Start from a concrete key, list links, normalize linked keys, then fetch compact status snapshots for each linked issue.

Correct example:

```bash
acli jira workitem link list --key TEAM-123 --json
```

```bash
acli jira workitem link list --key TEAM-123 --json \
  | jq -r '.results[]?.key // .results[]?.outwardIssue?.key // .results[]?.inwardIssue?.key' \
  | sed '/^$/d' | sort -u \
  | while read -r linked; do
      acli jira workitem view "$linked" --fields "key,summary,status,assignee,priority,updated" --json
    done
```

Wrong example:

```bash
# Wrong: fetches only source ticket and assumes links are visible there
acli jira workitem view TEAM-123 --fields "summary,status" --json
```

Why wrong: this misses linked ticket state and gives no dependency picture.

## 12) Generate a manual Jira update draft (read-only)

Goal: provide paste-ready text the user can manually add to Jira, without any write operations.

Input needed from user:

- Ticket key or Jira URL.
- Work notes (code changes, testing done, blockers, next step).

Read-only command pattern:

```bash
acli jira workitem view TEAM-123 --fields "key,summary,status,assignee,priority,updated,description,comment,issuelinks" --json
```

Optional context command:

```bash
acli jira workitem comment list --key TEAM-123 --order -created --limit 20 --json
```

Recommended output template (under 30 seconds to read):

```text
Update for TEAM-123

Progress
- <completed item 1>
- <completed item 2>

Validation
- <tests/checks run>

Risks/Blockers
- <blocker or None>

Next
- <next concrete action>
```

Wrong example:

```text
# Wrong: long narrative with no structure and no next action
Did lots of work on this ticket, changed many files, things look better now and hopefully we can finish soon.
```

Why wrong: not scan-friendly, not actionable, and hard to paste into Jira updates.
