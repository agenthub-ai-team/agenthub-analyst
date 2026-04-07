---
name: GitHub
icon: "🔄"
type: tool
description: >
  Read, download, and write to GitHub. Supports searching repos and code,
  reading PRs and files, cloning repos locally via SSH, and creating issues,
  PRs, comments, and branches through the GitHub MCP server.
use_when: >
  User wants to read, search, download, clone, or write anything on GitHub.
  Keywords: "github", "clone repo", "search code", "create issue", "open PR",
  "download repo", "fetch repo locally".
not_when: >
  The task has no GitHub component (e.g., purely local file editing or
  non-GitHub services).
prompts: "mcp-tools/github/prompts.md"
output: "documentation/github/[platform]/[repo-name]/"
auto_discover: []
---

# GitHub

Read and follow the shared rules in `mcp-tools/instructions.md`.

## Details

- **Source:** GitHub MCP wired in `.mcp.json` plus SSH-based `git clone`
- **Prompts:** `mcp-tools/github/prompts.md`
- **Default output:** `documentation/github/[platform]/[repo-name]/`
- **Auth for clone:** SSH (`git@...`) — no token needed
- **Auth for MCP:** GitHub PAT configured in `config/.env`

## GitHub Instance Detection

This workspace supports **two GitHub instances simultaneously**:

| Instance | MCP server name | Env vars | When to use |
|----------|----------------|----------|-------------|
| **github.com** | `github` | `GITHUB_PERSONAL_ACCESS_TOKEN` | Public GitHub or github.com-hosted orgs |
| **GitHub Enterprise** | `github-enterprise` | `GITHUB_ENTERPRISE_HOST`, `GITHUB_ENTERPRISE_PAT` | Self-hosted GitHub Enterprise Server |

**How to determine which instance to use:**

1. Check the repo URL or org name the user provides
2. If it's `github.com/...` or `git@github.com:...` → use the `github` MCP server
3. If it's a custom domain (e.g., `github.yourcompany.com/...`) → use the `github-enterprise` MCP server
4. If unclear, check `GITHUB_ENTERPRISE_HOST` in `config/.env` — if the host matches the user's URL, use `github-enterprise`
5. When in doubt, ask the user which instance they mean

## Available Tools

| Tool | Mode | Description |
|------|------|-------------|
| `search_repositories` | Read | Search for repos by name or topic |
| `search_code` | Read | Search code across repos |
| `get_file_contents` | Read | Read a specific file from a repo |
| `get_pull_request` | Read | Read PR details and diffs |
| `git clone` (SSH) | Download | Clone full repo locally |
| `create_issue` | Write | Open a new GitHub issue |
| `create_pull_request` | Write | Open a pull request |
| `add_issue_comment` | Write | Comment on an issue or PR |
| `create_branch` | Write | Create a new branch remotely |
| `create_or_update_file` | Write | Push a file change directly |

## Download

When this tool is selected, the assistant must clone or fetch GitHub repository content locally for offline analysis.

### 1. Create the standard folder structure

Save cloned repos under:

```text
documentation/github/[platform]/[repo-name]/
```

Where:

- `[platform]` is a category the user provides (e.g., `web`, `backend`, `mobile`, `infra`)
- `[repo-name]` is the repository name extracted from the clone URL or GitHub MCP

If the user does not specify a platform, ask for one or default to `general`.

### 2. Always use SSH for cloning

Clone via SSH URLs:

**github.com:**
```text
git clone git@github.com:ORG/REPO.git documentation/github/[platform]/[repo-name]/
```

**GitHub Enterprise** (use the host from `GITHUB_ENTERPRISE_HOST` in `config/.env`):
```text
git clone git@GITHUB_ENTERPRISE_HOST:ORG/REPO.git documentation/github/[platform]/[repo-name]/
```

Never use HTTPS clone URLs. If the user provides an HTTPS URL, convert it to SSH form.

### 3. Support branch selection

If the user requests a specific branch:

```text
git clone -b BRANCH --single-branch git@github.com:ORG/REPO.git documentation/github/[platform]/[repo-name]/
```

For GitHub Enterprise, replace `github.com` with the `GITHUB_ENTERPRISE_HOST` value.

If no branch is specified, clone the default branch.

### 4. Support shallow clones for large repos

If the user explicitly asks for a lightweight clone, or the repo is known to be very large:

```text
git clone --depth 1 git@github.com:ORG/REPO.git documentation/github/[platform]/[repo-name]/
```

For GitHub Enterprise, replace `github.com` with the `GITHUB_ENTERPRISE_HOST` value.

Do not shallow-clone by default — full history is useful for analysis.

### 5. Skip re-cloning if the directory already exists

If `documentation/github/[platform]/[repo-name]/` already exists and contains a `.git` directory:

- Do **not** re-clone
- Instead, run `git pull` to update
- Tell the user the repo was updated rather than freshly cloned

### 6. Use GitHub MCP for non-clone tasks

For tasks that don't require a full clone, use the GitHub MCP server directly:

- **Fetch specific file contents** — use `get_file_contents` instead of cloning the whole repo
- **Read PR diffs** — use `pull_request_read` with `get_diff`
- **Search code** — use `search_code` for finding specific patterns across repos
- **List repo structure** — use `get_file_contents` with the root path

Only clone when the user needs the full repo locally for offline work.

### 7. Resolve repos via GitHub MCP when needed

If the user provides a partial reference (e.g., "clone the auth service repo"):

1. Use `search_repositories` to find matching repos
2. Confirm with the user which repo to clone
3. Proceed with the SSH clone

### 8. Handle errors clearly

- **SSH auth failure** — tell the user to check their SSH key is added to GitHub (`ssh -T git@github.com` for github.com, `ssh -T git@GITHUB_ENTERPRISE_HOST` for Enterprise)
- **Repo not found** — verify the org/repo name via GitHub MCP `search_repositories`
- **Permission denied** — the user may need repo access granted by an admin

---

## Write

GitHub supports creating and updating issues, PRs, and comments through GitHub MCP. Follow the shared write rules in `mcp-tools/instructions.md`.

### Supported write actions

| Action | MCP tool | When to use |
|--------|----------|-------------|
| Create issue | `create_issue` | User wants to open a new GitHub issue |
| Create PR | `create_pull_request` | User wants to open a pull request |
| Add comment | `add_issue_comment` | User wants to comment on an issue or PR |
| Create branch | `create_branch` | User wants to create a new branch remotely |
| Push files | `create_or_update_file` | User wants to push a file change directly |

### Create an issue

1. Confirm the **repo** (org/name), **title**, and **body**
2. Show a preview of the issue
3. After approval, call `create_issue`
4. Report the issue URL

### Create a pull request

1. Confirm the **repo**, **head branch**, **base branch**, **title**, and **body**
2. Show a preview including the diff summary (use `compare_commits` if needed)
3. After approval, call `create_pull_request`
4. Report the PR URL

### Add a comment

1. Show the comment text and target issue/PR number
2. After approval, call `add_issue_comment`
3. Confirm the comment was added
