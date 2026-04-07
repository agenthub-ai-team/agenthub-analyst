# Onboarding Guide

Welcome to AgentHub Analyst. Follow these steps to get started.

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/agenthub-ai-team/agenthub-analyst.git
cd agenthub-analyst
```

## Step 2: Choose Your AI Tool

MCP servers give the AI live access to external tools (Jira, Confluence, GitHub, etc.). Not every AI tool supports MCP — here's the distinction:

| Tool | Where it lives | MCP support | What it's for |
|------|---------------|-------------|---------------|
| **Copilot Chat** | VS Code sidebar (built-in) | No MCP | Code completions, general questions, code review |
| **Claude Code** | VS Code sidebar (extension) or terminal | Full MCP | Live queries, analysis, structured investigations |
| **Cursor** | Standalone IDE (VS Code fork) | Full MCP | Same as Claude Code, IDE with built-in AI |
| **Copilot CLI** | Separate terminal window | Full MCP | Same as Claude Code, but runs in the terminal |

> **Don't confuse them:** Copilot Chat and Copilot CLI sound similar but are completely different tools. Copilot Chat is the built-in VS Code chat panel — it **cannot** access MCP servers. Copilot CLI is a standalone terminal agent you launch with `copilot` in a separate terminal window — it **can** access MCP servers.

### Option A: Claude Code (recommended)

Claude Code runs inside VS Code or as a terminal tool. It provides full MCP support with fast responses.

- **VS Code extension:** Install "Claude" (by Anthropic) from the Extensions panel
- **Terminal:** Install via `npm install -g @anthropic-ai/claude-code` or see [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code)

### Option B: Cursor

Cursor is a VS Code fork with built-in AI and full MCP support. MCP config is auto-generated at `.cursor/mcp.json` by `setup.sh`.

- Download from [cursor.com](https://cursor.com)
- Open the project folder in Cursor — MCP servers load automatically

### Option C: Copilot CLI

If Claude Code doesn't work on your machine, Copilot CLI runs in a **separate terminal window** with full MCP support.

1. Install: `brew install copilot-cli` (macOS) / `curl -fsSL https://gh.io/copilot-install | bash` (Linux) / `winget install GitHub.Copilot` (Windows)
2. Verify version: `copilot --version` — must be >= 1.0.14 (MCP support)
3. Open a **separate terminal window** (not VS Code's integrated terminal)
4. Run `copilot` to start, then `/login` to authenticate

## Step 3: Configure Credentials

Edit `config/.env` and add your API credentials for the services you want to use.
See the [credentials table below](#where-to-get-credentials) for where to get each token.

> **Required:** At least one service must be configured for the setup wizard to succeed.
> You can add more services later.

## Step 4: Run the Setup Wizard

Open your AI tool (Claude Code or Copilot CLI) in the project directory and paste:

```
Set up my project. Follow guides/setup-wizard.md
```

Works with Claude Code (terminal or IDE), Copilot CLI, Cursor, or any MCP-compatible tool. The setup wizard auto-detects which tool you're using.

The AI will:
- Run `shellscripts/setup.sh` to check prerequisites and create workspace directories
- Install Copilot CLI if needed (for Copilot CLI users) and generate `~/.copilot/mcp-config.json`
- Verify your `config/.env` credentials
- Clean up common credential mistakes (trailing slashes, whitespace, etc.)
- Install required MCP server dependencies
- Validate live MCP connections (Claude Code) or provide validation instructions (Copilot CLI)
- Print a status table with next steps

---

## Where to Get Credentials

| Credential | Where to get it | Required permissions |
|---|---|---|
| `JIRA_URL` | Your Jira Cloud instance URL (e.g., `https://yourcompany.atlassian.net`) | — |
| `JIRA_USER` | Your Atlassian account email | — |
| `JIRA_API_TOKEN` | [Create an API token](https://id.atlassian.com/manage-profile/security/api-tokens) | Inherits from user permissions |
| `CONFLUENCE_URL` | Same as Jira URL (Atlassian Cloud) | — |
| `CONFLUENCE_USER` | Same as Jira user | — |
| `CONFLUENCE_TOKEN` | Same as Jira API token | Inherits from user permissions |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [Create a PAT](https://github.com/settings/tokens) | Inherits from user permissions |
| `GITHUB_ENTERPRISE_HOST` | (Optional) GHE hostname, e.g., `github.yourcompany.com` | — |
| `GITHUB_ENTERPRISE_PAT` | (Optional) PAT for your GitHub Enterprise instance | Inherits from user permissions |

---

## What's Next

After setup, try your first analysis:

```
Investigate the checkout bug PROJ-123
```

or:

```
Explore how the subscription renewal flow works across web and backend
```

The Analyst agent will automatically query your connected tools (Jira, GitHub, Confluence)
and produce a structured investigation with evidence, root cause analysis, and actionable next steps.

---

## Upgrade to AgentHub Pro

Like the Analyst? The full version adds:
- 4 more specialized agents (BDD Requirement Engineers for web/backend/mobile + Documentation Generator)
- Automatic agent selection — one prompt, right agent, every time
- Tool chaining — "Fetch Jira epic → Generate BDDs → Publish to Confluence" in one prompt
- Prompt templates for every workflow

[See everything AgentHub Pro includes →](pro.md) | [Get AgentHub Pro](https://agenthub.gumroad.com/l/agenthub)
