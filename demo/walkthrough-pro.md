# AgentHub — What It Can Do

> You ask a question in plain English.
> The right specialist picks it up, reads your project sources, and delivers structured output.

---

AgentHub includes specialized agents for investigation, requirements, and documentation — all connected to your Jira, Confluence, GitHub, Swagger, Figma, and PostHog data. Here's what that looks like in practice:

---

## "We have a bug and nobody knows the root cause"

You're in a standup. Someone mentions users in one market are seeing blank screens. The Jira ticket has two sentences. You're supposed to figure out what happened.

> "Users in the north-market region are seeing a blank page when they click a promoted product. Can you investigate?"

You get back a structured report: what's happening, the root cause, which code is responsible, which teams should fix it, what the immediate patch looks like, and what should change long-term so this doesn't happen again. Every claim references a Jira ticket, a Confluence page, or a line in the codebase. Contradictions between your documentation and your code are flagged.

Instead of 2 hours of tab-switching between Jira, Confluence, and GitHub, you have an answer in minutes — with evidence your team can verify.

---

## "We're starting a new feature and need requirements"

Sprint planning is in two days. The epic is in Jira. There's a Confluence spec that's mostly complete. Figma has the designs. The API contract exists in Swagger. But nobody has turned all of that into structured acceptance criteria yet.

> "Write the acceptance criteria for subscription management — web, US market."

You get a complete set of testable scenarios covering the happy path, configuration, responsive behavior, edge cases, error paths, validation rules, accessibility, performance, and analytics — all in one standardized format. Every scenario traces back to the Jira ticket, Confluence spec, Swagger endpoint, or GitHub component it came from. Items that are undefined or contradictory in the source documents are flagged for the team to resolve.

> "Do the same for the backend API."

A separate output focused on API behavior — expected status codes, validation rules, security checks, data integrity, concurrency, and integration events. Scenarios are validated against the actual backend implementation in GitHub. No overlap with the web output. Each one is purpose-built for its audience.

> "And mobile — iOS first, then Android."

Mobile-specific coverage added: offline behavior, background/foreground transitions, biometric re-auth, VoiceOver support, Dynamic Type, device-specific form factors. Separate files per platform.

One feature, three prompts, full cross-platform requirement coverage. Ready for sprint planning.

---

## "Quick question — I just need to check something"

Not everything requires a deep analysis or a full download. Sometimes you just need a quick answer from one of your project tools.

> "What's the status of PROJ-4821 in Jira? Is it still in progress or did someone close it?"

The agent checks Jira live and gives you the current status, assignee, and latest comment — without saving anything locally. A 10-second lookup instead of opening Jira in the browser.

> "What endpoints does the subscription API expose? I need the paths and methods."

A live lookup against your Swagger spec. You get back the endpoint list with methods, paths, and descriptions. No download, no local files — just the answer.

> "Is the feature flag `orders.subscriptionManagement` currently enabled in PostHog? For which regions?"

A quick check against PostHog. You get the flag status, targeting rules, and which regions it's active for. Useful before a release or when debugging why something isn't showing up.

> "What did the last pull request change in the checkout module?"

The agent checks GitHub live — gives you the PR title, files changed, and a summary of what was modified. Faster than navigating to GitHub and reading the diff yourself.

> "Does the Confluence page for the refund policy mention anything about partial refunds?"

A live read of the Confluence page. You get the relevant section back — or a clear answer that it's not covered. Useful when you need to reference a spec during a conversation without leaving your IDE.

These quick lookups use the same source connections as the deep analysis — but without downloading anything. Ask, get the answer, move on.

---

## "The new person starts Monday and there are no docs"

A new engineer is joining the team. The feature they'll work on has dozens of Jira tickets, a handful of Confluence pages, scattered Slack threads, and no single place that explains the whole picture.

> "Generate documentation for the Order Management Dashboard."

You get a business overview page (what it does, which regions and platforms, who the team is), a roadmap page (release timeline, rollout status, feature flags), and technical detail pages — all assembled from your existing Jira, Confluence, Swagger, GitHub, and Figma data. Not from someone's memory. Not from a stale slide deck that was last updated 6 months ago.

The new engineer reads 4 pages and understands the feature. Instead of spending their first week asking "where do I find...?"

---

## "Product wants a status update and I don't have time"

Your product manager needs a document showing which markets are live, what's planned for next quarter, which partners are affected, and what the technical footprint looks like. That information exists — across Jira, Confluence, and your API specs — but pulling it together is a half-day job.

> "Generate a status overview for the payments feature — markets, roadmap, partner impact, and technical summary."

Four structured pages come back. Region-by-region rollout status. Quarterly timeline. Integration requirements per partner. Endpoint inventory with error handling. All sourced from real project data, all internally consistent.

You review it, adjust anything that needs a human touch, and send it. Total time: 15 minutes instead of 4 hours.

---

## "We think we can reuse this, but we're not sure"

Your mobile team wants to reuse the web subscription flow. The question is: how much of the backend is shared? What's new? What's the risk?

> "How much of the subscription management backend can the mobile app reuse? What gaps exist for iOS and Android?"

You get a feasibility breakdown: which endpoints work as-is, which need mobile-specific extensions, what's missing entirely, and where the biggest development effort sits. Grounded in the actual API spec and the existing web implementation — not a whiteboard guess.

---

## "We need QA coverage and it's always the last priority"

The team ships features fast but test coverage is always playing catch-up. Edge cases get discovered in production. Accessibility gets skipped. Analytics events are forgotten until someone asks "why isn't PostHog showing data?"

> "Review our existing BDD scenarios for the checkout flow and identify what's missing — especially edge cases, accessibility, and analytics."

You get a gap analysis: which sections have coverage, which don't, and net-new scenarios for what's missing — written in the same BDD format your team already uses. No rework needed, just fill in the blanks.

---

## "Someone changed something and now things are different"

A release went out and the behavior doesn't match the spec anymore. Or maybe the spec was updated but nobody told the developers. You need to know what's out of sync.

> "Compare the subscription management Confluence spec against what's actually implemented in GitHub and the Swagger contract. What's mismatched?"

The analyst reads all three sources, cross-references them, and produces a conflict report. You see exactly where the spec says one thing but the code does another — with file paths and Jira ticket references. No guessing, no "I think it changed in the last sprint."

---

## "We need to get all the context in one place before we start"

The feature you're about to build has information scattered across 3 Jira epics, 5 Confluence pages, 2 Swagger specs, and a Figma file. Before any agent can do useful work, you need all of that in one place.

> "Download all the Jira tickets, Confluence pages, and API specs for the loyalty program feature."

Everything gets saved locally under a single folder. Now when you ask for analysis, requirements, or documentation, the agents read from a complete, consistent snapshot of your project sources — instead of making live calls that might miss something or hit rate limits.

---

## "I need to push the results back to where the team will actually see them"

You generated great documentation or a solid bug analysis. But it's sitting in your local repo. Your team lives in Confluence and Jira.

> "Update the Confluence page for subscription management with the documentation we just generated."

> "Post the bug analysis as a comment on PROJ-4821."

> "Create a GitHub issue with the findings from the investigation."

The system generates locally first, shows you a preview, and only publishes after you confirm. Nothing goes to an external system without your approval.

---

## Combining Agents

The real power is chaining agents in a single request.

> "Pull all the Jira and Confluence docs for the payments feature, then investigate the refund bug, and generate updated documentation."

Three steps run in sequence: download sources, analyze the problem, produce documentation — all from one prompt.

> "Generate web, backend, and mobile requirements for the loyalty program, then create the documentation pages."

Requirement engineers produce the BDD files, then the documentation generator creates the feature overview — all grounded in the same sources.

> "Check the current status of the subscription epic in Jira, then generate requirements for whatever tickets are still open."

A live lookup feeds into a generation step. The agent checks what's current, then produces output based on the latest state — no stale data.

---

## "We want all of this for every feature, not just this one"

The real value isn't one great output. It's getting the same quality every time, from everyone on the team.

The same analyst produces the same structured investigation whether a senior engineer asks or a junior PM asks. The same requirement engineer generates the same coverage sections whether it's your most experienced BA or someone who joined last week. The same documentation generator creates the same page structure whether it's sprint 1 or sprint 50.

Your AI process lives in the repo, not in someone's head. It's reviewable in pull requests, improvable over time, and shared across the whole team.

---

*Full output examples for every agent: see `agents/*/examples/`*

---

*Want to see what you'd get without the workspace? See the before/after comparisons:*
- [Bug Investigation](analyst-before-after.md)
- [Acceptance Criteria](acceptance-criteria-before-after.md)
- [Documentation](docs-before-after.md)
