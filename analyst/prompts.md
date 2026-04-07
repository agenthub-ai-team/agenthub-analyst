# Analyst Prompt Designs

## How It Works

The **Agent Router** automatically handles everything:
- Matches your prompt to the Analyst agent based on keywords (bug, investigate, explore, design, impact)
- Loads the agent's instruction file
- Discovers feature documentation from `documentation/[feature-name]/`

Just type your prompt. The router does the rest.

### Where the Agent Gets Its Data

You control how the agent accesses project context. Three options — use whichever fits your workflow:

| Mode | How | Best for |
|------|-----|----------|
| **Live MCP** | The agent queries Jira, Confluence, GitHub, Swagger, etc. in real time via MCP servers | Quick lookups, always up-to-date |
| **Local docs** | Download data first (`Download Jira epic PROJ-500 into myFeature`), then run the agent on local files | Offline work, large datasets, repeatable runs |
| **Manual context** | Drag and drop files into chat, or use `#` / `@` to reference specific files | When you already have what you need on your machine |

You can combine all three — for example, work from local docs but let the agent do a live MCP lookup when it needs something that wasn't downloaded.

---

## Bug Investigation Prompts

### 1. Investigate a Bug - Full Analysis

```
Mode: Bug
Investigate [DESCRIBE_THE_BUG] in [YOUR_FEATURE].

Platform: [Web / iOS / Android / Backend / All]
Environment: [Production / Staging / QA]
Jira ticket: [TICKET_ID]

Provide root cause analysis, code locations, historical context, system impact, and recommended fix.
```

**Variables:**
- `[DESCRIBE_THE_BUG]` - e.g., "redirect failure after parameter change", "payment timeout on submit"
- `[TICKET_ID]` - e.g., PROJ-123 (optional -- omit if unknown)

---

### 2. Investigate a Bug - Quick Triage

```
Mode: Bug
Quick triage of [DESCRIBE_THE_BUG] in [YOUR_FEATURE].

Focus on:
- What is broken and who is affected
- Most likely root cause
- Immediate mitigation steps
```

---

### 3. Investigate a Bug - Cross-Platform Impact

```
Mode: Bug
Analyze cross-platform impact of [DESCRIBE_THE_BUG] in [YOUR_FEATURE].

Found on [PLATFORM]. Determine:
- Does this affect other platforms?
- Are there shared components or APIs involved?
- Which regions are impacted?
```

**Variables:**
- `[PLATFORM]` - e.g., "web", "iOS", "backend"

---

### 4. Investigate a Production Incident

```
Mode: Bug
Investigate production incident for [YOUR_FEATURE].

What happened: [DESCRIBE_INCIDENT]
When it started: [DATE/TIME or "unknown"]
Affected users/regions: [SCOPE]

Provide timeline reconstruction, root cause, blast radius, immediate fix vs long-term solution, and prevention recommendations.
```

---

## Exploration & Solution Design Prompts

### 5. Explore a Feature - How It Works

```
Mode: Exploration
Explain how [YOUR_FEATURE] works across all platforms.

Cover:
- User-facing behavior
- Technical flow (frontend -> backend -> external services)
- Key API endpoints and data models
- Region variations
- Feature flags and configuration
```

---

### 6. Explore a Feature - Specific Platform

```
Mode: Exploration
Explain how [YOUR_FEATURE] works on [PLATFORM].

Focus on:
- User flow from entry to completion
- Technical implementation details
- API calls and data flow
- Error handling and edge cases
- Integration points with other features
```

**Variables:**
- `[PLATFORM]` - web, iOS, android, or backend

---

### 7. Solution Design - New Requirement

```
Mode: Exploration
Design a solution for [DESCRIBE_REQUIREMENT] in [YOUR_FEATURE].

Current behavior: [WHAT_EXISTS_TODAY]
Desired behavior: [WHAT_SHOULD_CHANGE]
Constraints: [ANY_CONSTRAINTS]

Provide at least 2 options with trade-offs and a recommendation.
```

---

### 8. Solution Design - Feature Extension

```
Mode: Exploration
Design how to extend [YOUR_FEATURE] to support [NEW_CAPABILITY].

Analyze current architecture, what needs to change, backward compatibility, and rollout strategy. Provide at least 2 options with trade-offs.
```

**Variables:**
- `[NEW_CAPABILITY]` - e.g., "target amount savings goal", "multi-currency support", "scheduled execution"

---

### 9. Impact Analysis

```
Mode: Exploration
Assess the impact of [DESCRIBE_CHANGE] on [YOUR_FEATURE].

Determine:
- Which components and platforms are affected
- Which regions are impacted
- Which teams need to be involved
- Risk level (low / medium / high)
- Testing requirements
```

**Variables:**
- `[DESCRIBE_CHANGE]` - e.g., "migrating from API v1 to v2", "changing validation rules for amount field"

---

### 10. Dependency Analysis

```
Mode: Exploration
Map all dependencies for [YOUR_FEATURE].

Include upstream, downstream, shared components, external integrations, data dependencies, and feature flag dependencies.
```

---

## Quick Reference

| **Need** | **Prompt** | **Mode** |
|----------|-----------|----------|
| Full bug investigation | #1 | Bug |
| Quick bug triage | #2 | Bug |
| Cross-platform bug impact | #3 | Bug |
| Production incident | #4 | Bug |
| Feature exploration (all platforms) | #5 | Exploration |
| Feature exploration (single platform) | #6 | Exploration |
| Solution design (new requirement) | #7 | Exploration |
| Solution design (feature extension) | #8 | Exploration |
| Impact analysis | #9 | Exploration |
| Dependency mapping | #10 | Exploration |

---

## Output Structure

```
output/analysis/
├── [feature]_bug_investigation.md
├── [feature]_triage.md
├── [feature]_cross_platform_impact.md
├── [feature]_incident_report.md
├── [feature]_exploration.md
├── [feature]_[platform]_exploration.md
├── [feature]_solution_design.md
├── [feature]_extension_design.md
├── [feature]_impact_analysis.md
└── [feature]_dependencies.md
```

---

## Tips

**DO:**
- Specify the mode (Bug or Exploration) for best results
- Include the Jira ticket ID when investigating bugs
- Mention the platform(s) involved
- Paste error messages or logs directly into the prompt
- Use `#` / `@` to pull in specific Jira tickets or Confluence pages

**DON'T:**
- Assume a single platform when the bug might be cross-platform
- Ask for BDD scenarios (use the Requirement Engineers instead)
- Ask for documentation pages (use the Documentation Generator instead)

---

## Example Workflow

### Scenario: Investigate a Bug Found in Production

**Step 1: Fetch Documentation** (optional -- the agent can query MCP live)
```
Download all Jira tickets and Confluence pages for Subscription Management
```

**Step 2: Investigate**
```
Mode: Bug
Investigate subscription renewal failure for EU region customers after the Stripe webhook migration.

Platform: Web
Environment: Production
Jira ticket: BILL-3042

Provide root cause analysis, code locations, historical context, system impact, and recommended fix.
```

**Step 3: Act on Results**
- Check root cause and code locations
- Verify impact scope (regions, platforms)
- Use the recommended fix as starting point
- Follow up on TO CLARIFY items
