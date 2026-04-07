# Security & Data Privacy

Everything you need to know about how AgentHub Analyst handles your data, where it goes, and what stays on your machine.

**The short version:** AgentHub Analyst is a local-first AI agent. It runs entirely within your repository — no backend, no hosted service, no database. It structures your AI tool's analysis without routing your data anywhere.

---

## How It Works — The Architecture

AgentHub Analyst is a **structured AI agent** that sits between you and your AI tools. It provides structured instructions and quality enforcement — all running locally within your project.

```
Your prompt
    ↓
AgentHub Analyst (structured instructions + quality enforcement)
    ↓
Your AI tool (Claude Code / Copilot / Cursor — already on your machine)
    ↓
MCP Servers (optional — connect to YOUR tools with YOUR credentials)
    ↓
Generated output (saved locally in output/)
```

At every step in this chain:
- **Nothing leaves your machine** unless you explicitly connect an MCP server
- **No middleware, no proxy, no relay** — the framework operates entirely within your repo
- **No telemetry, no analytics, no tracking** — there is no external service to report to

---

## What AgentHub Analyst Is

- A structured AI analysis agent with quality enforcement and output templates
- A production-grade tool for bug investigation, feature exploration, and impact analysis
- A repeatable, auditable workflow for technical analysis
- 3 pre-configured MCP integrations (Jira, Confluence, GitHub)
- An automated setup system that detects your AI tool, installs dependencies, and wires MCP servers
- Onboarding, security, and setup wizard guides
- Works across Claude Code, GitHub Copilot CLI, and Cursor — no vendor lock-in

## What AgentHub is NOT

- Not a hosted service — there is no running server or process
- Not a proxy — it does not sit between you and your AI provider
- Not a data collector — it stores nothing about your usage
- Not an external dependency — it lives in your repository and works offline

---

## MCP Connections — Your Tools, Your Credentials

MCP (Model Context Protocol) servers are **optional** integrations that let your AI tool query external services. These are configured by you, pointing to your own tools.

| Tool | What it connects to | Who controls it |
|------|-------------------|-----------------|
| Jira | Your Jira instance | You — your token, your permissions |
| Confluence | Your Confluence instance | You — your token, your permissions |
| GitHub | Your GitHub repos | You — your token, your permissions |

**Key points:**
- Every MCP connection uses **your personal credentials** stored in `config/.env`
- The AI can only access what **your token has permission to access**
- If you don't configure a tool, it simply isn't available — nothing breaks

---

## Where Your Credentials Live

Your API tokens are stored in `config/.env`. This file ships with **placeholder values** and is tracked by git with those placeholders. You replace them with your real tokens locally.

```
config/.env          ← Ships with placeholders; you add real tokens locally
.gitignore           ← Ignores root-level .env files
```

**Safeguards built in:**
- `config/.env` is committed with placeholder values only — never push real credentials to remote
- The setup wizard guides you through generating tokens with minimum required scopes
- Shell scripts include placeholder detection — they refuse to run with dummy values
- PR review rules flag any hardcoded credentials in code reviews

---

## What Stays Local — Always

| What | Where it stays |
|------|---------------|
| Your prompts | Processed by your AI tool locally |
| Agent instructions | Within the framework in your repo |
| Analysis output | `output/` folder on your machine |
| Your credentials | `config/.env` on your machine |

**Nothing is uploaded, synced, or shared** unless you explicitly push to git.

---

## What Touches External Services

The only time anything reaches an external service:

| Action | What happens | When |
|--------|-------------|------|
| MCP query | Your AI tool queries Jira/Confluence/GitHub/etc. using your token | When you ask the AI to look something up |
| AI model call | Your prompt is sent to the AI provider (Anthropic, OpenAI, etc.) | Every time you interact with the AI |

These are the same services your AI tool already connects to — AgentHub Analyst does not introduce any new external connections. It structures **how** your AI tool uses the connections you already have.

---

## Access Control Summary

| Layer | Who controls it |
|-------|----------------|
| AI provider access | Your license (Copilot seat, Claude subscription, Cursor subscription) |
| MCP tool access | Your personal API tokens in `config/.env` |
| Repository access | Your git permissions |
| Agent behavior | The instruction files in `analyst/` — fully visible and editable by you |

You own every layer. There is no shared state, no central server, no admin panel.

---

## Common Questions

| Question | Answer |
|----------|--------|
| Can AgentHub Analyst access my data without me knowing? | No. The framework has no background process — it only activates when you interact with your AI tool. |
| Does it send my code or prompts to a third party? | No. Your AI tool handles model communication (Claude, Copilot, Cursor). AgentHub Analyst does not add any new destinations. |
| Can someone else see what I generate? | No. All output stays in your local repo unless you explicitly push it. |
| What if I don't configure any MCP servers? | The agent still works — it analyzes whatever context you provide manually (paste code, drag files, `#`, `@`). |
| Is there a risk of credential leakage? | Credentials are gitignored and scripts reject placeholder values. |
| Can I audit the agent's behavior? | Yes. The agent instructions are in `analyst/instructions.md` — fully transparent and editable. |
| Does removing the repo remove all traces? | Yes. Delete the folder and everything is gone. No external state is maintained. |

---

## In One Sentence

AgentHub Analyst is a local-first AI agent that structures your analysis with quality enforcement and evidence-based output — it introduces no new external connections, stores no data outside your repo, and gives you full control over every layer.
