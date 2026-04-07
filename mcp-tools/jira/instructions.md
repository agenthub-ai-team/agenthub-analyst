---
name: Jira
icon: "🔄"
type: tool
description: >
  Read, download, and write Jira issues through Atlassian MCP.
  Read returns live answers; Download saves raw JSON and attachments locally;
  Write creates or updates issues, comments, and transitions.
use_when: >
  User wants to look up, search, download, create, update, comment on, or
  transition Jira issues.
not_when: >
  The request has nothing to do with Jira.
prompts: "mcp-tools/jira/prompts.md"
output: "documentation/[feature]/jira/"
auto_discover: []
---

# Jira

Read and follow the shared rules in `mcp-tools/instructions.md`.

## Details

- **Source:** Atlassian MCP wired in `.mcp.json` and loading credentials from `config/.env`
- **Prompts:** `mcp-tools/jira/prompts.md`
- **Output:** `documentation/[feature]/jira/`
- **Depth default:** `0` (single issue only unless the user asks for recursive traversal)

## Available Tools

| Tool | Mode | Description |
|------|------|-------------|
| `jira_get_issue` | Read | Look up a single Jira issue |
| `jira_search` | Read | Search issues via JQL |
| `jira_get_issue` + save | Download | Save issue JSON locally with recursive traversal |
| `jira_create_issue` | Write | Create a new Jira issue |
| `jira_update_issue` | Write | Update fields on an existing issue |
| `jira_add_comment` | Write | Add a comment to an issue |
| `jira_transition_issue` | Write | Change issue status |

## Download

When this tool is selected, the assistant must use Atlassian MCP to save Jira work locally for offline analysis without generating Markdown unless the user explicitly asks for it.

### 1. Create the same folder structure

Create:

- `documentation/[feature]/jira/raw/`
- `documentation/[feature]/attachments/`

If the user explicitly requests an attachments subdirectory, save attachments under:

- `documentation/[feature]/attachments/[subdir]/`

### 2. Track processed issues to avoid duplicates

Maintain a processed-issues set for the run. Never re-fetch or re-save an issue key that has already been processed in the same run.

### 3. Validate the Jira key format

Only accept issue keys matching:

```text
[A-Z]+-[0-9]+
```

If the format is invalid, stop and report the validation error.

### 4. Save the raw issue payload

For every processed issue key `PROJ-123`, save the expanded raw Jira response to:

```text
documentation/[feature]/jira/raw/issue-PROJ-123-expanded.json
```

### 5. Download attachments with the same naming convention

For every attachment in `.fields.attachment[]`:

- sanitize the filename by replacing `/` and spaces with `_`
- save as `documentation/[feature]/attachments/[KEY]_[safe_filename]`
- if the file already exists and is larger than 100 bytes, keep it
- if it exists but is too small, delete and re-download it

If the Atlassian MCP server exposes attachment metadata but not the file bytes directly, use the authenticated Jira attachment URL surfaced by the issue payload and save the file locally with the same filename and validation rules.

### 6. Reproduce the recursive traversal logic exactly

If `current_depth < max_depth`, run these three phases:

#### Phase 1 — children via JQL search

Run:

```text
parent = KEY OR "Epic Link" = KEY OR "Parent Link" = KEY
```

Save the raw search response to:

```text
documentation/[feature]/jira/raw/children-search-KEY.json
```

Collect issue keys from `.issues[]?.key`.

#### Phase 2 — linked issues from the issue payload

Collect related keys from all of the following:

1. `.fields.issuelinks[]` outward and inward issue keys
2. `.fields.subtasks[]?.key`
3. `.fields.parent?.key`
4. `.fields.customfield_10014`
5. If the current issue type is `Epic`, also run `cf[10014]=KEY`, save that response to `documentation/[feature]/jira/raw/epic-search-KEY.json`, and collect `.issues[]?.key`
6. Scan all custom fields for values that resolve to Jira keys matching `[A-Z]+-[0-9]+`

#### Phase 3 — combine and recurse

- combine Phase 1 children and Phase 2 linked issues
- keep only valid Jira keys
- remove duplicates
- skip the current issue key itself
- recurse into each related issue with `next_depth = current_depth + 1`

### 7. Preserve the intended Jira local-sync behavior without Markdown conversion

This tool is successful only if it preserves the intended Jira local-sync behavior while intentionally omitting the Markdown conversion step:

- raw expanded issue JSON
- raw child-search JSON
- raw epic-search JSON when relevant
- downloaded attachments

Do not create `documentation/[feature]/jira/processed/` or `issues-list.txt` unless the user explicitly asks for human-readable local docs in addition to the JSON sync.

---

## Write

Jira supports creating and updating issues through Atlassian MCP. Follow the shared write rules in `mcp-tools/instructions.md`.

### Supported write actions

| Action | MCP tool | When to use |
|--------|----------|-------------|
| Create issue | `jira_create_issue` | User wants to create a new Jira ticket |
| Update issue | `jira_update_issue` | User wants to update fields on an existing ticket |
| Add comment | `jira_add_comment` | User wants to add a comment to an existing ticket |
| Transition issue | `jira_transition_issue` | User wants to change issue status |

### Create a new issue

1. Confirm the **project key**, **issue type** (Story, Bug, Task, etc.), and **summary**
2. Show the user a preview: project, type, summary, description, and any other fields
3. After approval, call `jira_create_issue`
4. Report the new issue key and URL

### Update an existing issue

1. Fetch the current issue first to show what exists
2. Show what fields will change (summary, description, labels, assignee, etc.)
3. After approval, call `jira_update_issue`
4. Report the updated issue URL

### Add a comment

1. Show the comment text and the target issue key
2. After approval, call `jira_add_comment`
3. Confirm the comment was added
