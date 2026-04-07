# AgentHub Pro

**Everything in the free Analyst — plus 4 more agents, automatic routing, tool chaining, and full read/download/write access to all MCP integrations.**

One-time purchase. Lifetime updates. No subscription.

[Get AgentHub Pro →](https://agenthub.gumroad.com/l/agenthub)

---

## What's Included

### Specialized Agents

| Agent | What it does | Output |
|-------|-------------|--------|
| **Analyst** | Bug investigation, feature exploration, impact analysis | Structured report with root cause, evidence tables, conflict detection, TO CLARIFY items |
| **Requirement Engineer (Web)** | Web features, UI/UX, responsive design | 20+ BDD scenarios across 10 sections — main flow, validation, edge cases, responsive, accessibility, performance, analytics |
| **Requirement Engineer (Backend)** | APIs, services, data integrity | 20+ BDD scenarios with API contract validation, error codes, concurrency, security, data integrity |
| **Requirement Engineer (Mobile)** | iOS and Android features | Parallel platform-specific outputs — VoiceOver/TalkBack, Dynamic Type, offline, background/foreground lifecycle |
| **Documentation Generator** | Feature documentation from live project data | 4 structured pages: Landing, Roadmap & Team, Dependencies & Integration, Technical Implementation |

Every agent produces consistent, traceable output — regardless of who runs the prompt.

---

### Automatic Agent Selection

In the free version, you manually invoke the Analyst. In Pro, you just describe what you need. The routing system reads your prompt and selects the right agent automatically.

```
"Investigate the checkout bug"           → Analyst
"Write acceptance criteria for web"      → Requirement Engineer (Web)
"Generate backend BDD for payments API"  → Requirement Engineer (Backend)
"iOS requirements for push notifications"→ Requirement Engineer (Mobile)
"Document the order management feature"  → Documentation Generator
```

One prompt. Right agent. Every time.

---

### Route Chaining

Chain multiple agents and tools in a single prompt. No manual hand-off between steps.

```
"Fetch all Jira tickets for payments, then generate web BDDs"
→ Jira download → Requirement Engineer (Web)

"Analyze the refund bug, then document the findings"
→ Analyst → Documentation Generator

"Download docs for authentication, generate backend and mobile BDDs,
 then create the documentation pages"
→ Download tools → RE Backend → RE Mobile → Documentation Generator
```

Each step feeds its output to the next. Context flows through the chain automatically.

---

### Full MCP Tool Modes: Read + Download + Write

The free version is read-only. Pro unlocks all three modes across all six integrations.

| Mode | What it does | Saves files? | Needs confirmation? |
|------|-------------|-------------|---------------------|
| **Read** | Live lookups — query issues, search code, check flags | No | No |
| **Download** | Save data locally for offline analysis | Yes, under `documentation/` | No |
| **Write** | Create/update in external systems | No local files | Always |

#### Per-tool capabilities

| Tool | Read (free + Pro) | Download (Pro) | Write (Pro) |
|------|------------------|----------------|-------------|
| **Jira** | Search issues, read epics, sprints, comments | Save tickets locally as structured files | Create/update issues, post comments |
| **Confluence** | Search pages, read content and attachments | Save pages recursively with images | Create/update pages, post comments |
| **GitHub** | Search code, read PRs/issues/commits | Clone repos locally | Create PRs, issues, comments, branches |
| **Swagger** | Browse API specs, query endpoints and schemas | Save spec data locally | Register/remove spec portals at runtime |
| **Figma** | Inspect designs, read components and comments | Export images locally | Post, reply to, and delete comments |
| **PostHog** | Query feature flags, experiments, events | Save flags/events locally | Create/update feature flags, annotations |

The mode is auto-selected from your language:
- *"What's the status of PROJ-123?"* → Read
- *"Download the subscription epic"* → Download
- *"Post this analysis as a comment on PROJ-123"* → Write (confirms before publishing)

Nothing is ever written to an external system without your explicit approval.

---

### Prompt Templates

Pre-built prompts for every agent and every MCP tool — ready to use, no prompt engineering required.

- Agent templates for common workflows (bug triage, sprint planning BDDs, onboarding docs)
- Tool templates for common lookups (Jira sprint status, Confluence page search, GitHub PR review)

---

## Before & After: All Three Agents

See what the Pro agents produce compared to raw AI output:

- **[Bug Investigation](../demo/analyst-before-after.md)** — 5 guesses vs. 1 confirmed root cause with 6 cross-referenced sources
- **[Acceptance Criteria](../demo/acceptance-criteria-before-after.md)** — 9 flat scenarios vs. 24 structured scenarios with traceability matrix
- **[Documentation](../demo/docs-before-after.md)** — 1 generic page vs. 4 structured pages with region matrix, API schemas, and team contacts

---

## Free vs Pro

| Capability | Analyst (Free) | AgentHub Pro |
|---|---|---|
| Analyst agent | Included | Included |
| BDD Requirement Engineers (web / backend / mobile) | — | 3 agents |
| Documentation Generator | — | Included |
| Automatic agent selection | — | One prompt → right agent |
| Route chaining | — | Chain agents and tools in one prompt |
| MCP read mode | Included | Included |
| MCP download mode | — | Save docs locally |
| MCP write/publish mode | — | Publish back to Jira, Confluence, GitHub |
| Prompt templates | — | Pre-built for every workflow |
| AI tools supported | Claude Code, Copilot CLI, Cursor | Same |
| MCP integrations | 3 tools (Jira, Confluence, GitHub) | 6 tools (+Swagger, Figma, PostHog) |
| Setup wizard | Included | Included |
| Security model | Local-first, no telemetry | Same |

---

## How It Works

You describe what you need in plain English. The right agent picks it up, queries your project tools live, and delivers structured output — every time, from every team member.

- **No backend, no hosted service** — runs entirely in your repo
- **No telemetry** — nothing leaves your machine except queries to your own tools
- **No vendor lock-in** — works with Claude Code, Copilot CLI, and Cursor
- **Same quality from everyone** — a junior PM's bug report has the same structure and evidence as a senior engineer's

---

## What You Get

- **Private GitHub repo** with lifetime access to all updates
- 5 specialist agents with structured output templates
- Deterministic routing — automatic agent and tool selection
- Route chaining — multi-step workflows in one prompt
- Full read/download/write for all 6 MCP integrations (Jira, Confluence, GitHub + Swagger, Figma, PostHog)
- Prompt templates for every agent and tool
- Setup wizard, onboarding guide, security documentation
- 14-day money-back guarantee, no questions asked

---

## Get AgentHub Pro

**One-time purchase. Lifetime updates. No subscription.**

[Get AgentHub Pro →](https://agenthub.gumroad.com/l/agenthub)

After purchase, reply to the confirmation email with your GitHub username. You'll be invited to the private repo within 24 hours.
