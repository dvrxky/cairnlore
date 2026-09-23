## JQL patterns reference

Use this reference when the user asks for advanced read-only filtering.

### Operators

| Operator             | Example                                | Notes                  |
| -------------------- | -------------------------------------- | ---------------------- |
| `=`, `!=`            | `status = "Done"`                      | Exact match            |
| `~`, `!~`            | `summary ~ "login"`                    | Text contains          |
| `IN`, `NOT IN`       | `status IN ("To Do", "In Progress")`   | Multiple values        |
| `IS`, `IS NOT`       | `assignee IS EMPTY`                    | Null checks            |
| `>`, `>=`, `<`, `<=` | `created >= -7d`                       | Date/number comparison |
| `WAS`, `WAS NOT`     | `status WAS "In Progress"`             | Historical state       |
| `CHANGED`            | `status CHANGED FROM "Open" TO "Done"` | Change history         |

### Functions

| Function            | Purpose               | Example                             |
| ------------------- | --------------------- | ----------------------------------- |
| `currentUser()`     | Logged-in user        | `assignee = currentUser()`          |
| `now()`             | Current timestamp     | `due < now()`                       |
| `startOfDay()`      | Midnight today        | `created >= startOfDay()`           |
| `startOfWeek()`     | Start of current week | `created >= startOfWeek()`          |
| `startOfMonth()`    | Start of month        | `created >= startOfMonth("-1")`     |
| `endOfDay()`        | End of today          | `due <= endOfDay()`                 |
| `openSprints()`     | Active sprints        | `sprint IN openSprints()`           |
| `closedSprints()`   | Completed sprints     | `sprint IN closedSprints()`         |
| `membersOf("team")` | Group members         | `assignee IN membersOf("dev-team")` |

### Relative dates

- `-1d` = one day ago
- `-2w` = two weeks ago
- `-1M` = one month ago
- `-1y` = one year ago
- Example: `startOfDay("-3d")` means 3 days ago at midnight

### Operator precedence + parentheses

Use parentheses whenever mixing `AND` and `OR` so the intended logic is explicit.

Correct:

```jql
(assignee = currentUser() OR reporter = currentUser()) AND statusCategory != Done
```

Incorrect (ambiguous intent):

```jql
assignee = currentUser() OR reporter = currentUser() AND statusCategory != Done
```

### StatusCategory first pattern

Prefer `statusCategory` for cross-project stability, then narrow to specific statuses only when needed.

Stable baseline:

```jql
statusCategory != Done
```

Narrowed variant:

```jql
statusCategory = "In Progress" AND status IN ("In Progress", "Code Review")
```

### Text search constraints

Text search (`~`) is useful but can be noisy; scope it with project/time/status filters.

Good:

```jql
project = PROJ AND statusCategory != Done AND summary ~ "cards uplift"
```

Noisy:

```jql
text ~ "login"
```

### Advanced read-only query examples

```jql
project = MYPROJECT AND due < now() AND status != "Done"
```

```jql
project = MYPROJECT AND status = "In Progress" AND updated < -5d
```

```jql
assignee = currentUser() AND project IN ("PROJ-A", "PROJ-B") AND status != "Done" ORDER BY priority DESC
```

```jql
type = Bug AND sprint IN openSprints() AND priority IN ("High", "Critical") ORDER BY priority DESC, created ASC
```

```jql
project = MYPROJECT AND status CHANGED AFTER startOfWeek()
```

```jql
project = MYPROJECT AND assignee IS EMPTY AND sprint IS EMPTY AND status = "To Do"
```

```jql
project = MYPROJECT AND status CHANGED TO "Done" AFTER -7d AND assignee IN membersOf("dev-team")
```

### Ordering patterns

- `ORDER BY created DESC` (newest first)
- `ORDER BY priority DESC, created ASC` (highest priority then oldest)
- `ORDER BY updated DESC` (most recently touched)

### Sort strategies by use case

- **Triage queue:** `ORDER BY priority DESC, created ASC`
- **Standup/recent activity:** `ORDER BY updated DESC`
- **Fresh intake review:** `ORDER BY created DESC`
- **Aging work audit:** `ORDER BY updated ASC`

Examples:

```jql
assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC
```

```jql
type = Bug AND statusCategory != Done ORDER BY priority DESC, created ASC
```

### Common JQL mistakes

- Prefer quoted values: `status = "Done"`
- Use `currentUser()` instead of string literals like `"me"`
- Prefer sprint functions (`openSprints()`) over hardcoded sprint names when possible
- Prefer inclusive date boundaries where needed (`>=` instead of `>`)
