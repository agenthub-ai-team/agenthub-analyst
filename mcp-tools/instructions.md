# MCP Tools — Instructions

## Identity

These tools use MCP servers to interact with external systems. They support three modes:

- **Read** — live lookups and queries, no files saved
- **Download** — fetch data and save it locally under `documentation/` for offline agent use
- **Write** — push content back to external systems (create, update, publish)

## Core Rules

1. **NEVER print credentials or tokens in chat output**
2. **Use `config/.env` as the single source of truth for credentials** and `.mcp.json` only for MCP server wiring
3. If the required MCP server is missing or unavailable → tell the user which server is needed and point them to the relevant setup guide
4. Preserve the exact output paths, filenames, and folder structure defined in the matched tool instructions
5. Treat the matched MCP tool instruction file as the authoritative source of behavior for local sync, traversal, filenames, and saved artifacts
6. If an operation fails, explain the error clearly and suggest a fix (server not configured, expired token, no access, wrong issue key, etc.)

## Write Operations — Publish-Back Rules

When the user asks to create, update, or publish content to an external system (Jira, Confluence, GitHub), follow this flow:

### 1. Generate locally first

Always produce the artifact as a local file before publishing. The user should be able to review what will be written.

### 2. Preview before writing

Show the user what will be published:

- **Target** — which system and where (e.g., "Confluence page SPACE/123456", "Jira PROJ-456 comment")
- **Operation** — create, update, or append
- **Content summary** — a brief preview of the payload

### 3. Require explicit confirmation

**Never publish without the user's approval.** After showing the preview, ask:

> "Ready to publish this to [target]?"

Only proceed after a clear yes. If the user says no, keep the local file and stop.

### 4. Execute through MCP only

The actual write must go through the matched MCP server. Do not use shell scripts, `curl`, or direct API calls for write operations.

### 5. Report the result

After publishing, tell the user:

- Whether it succeeded or failed
- The URL or ID of the created/updated object
- Any errors with clear next steps

### What NOT to do

- Do not publish silently without preview + confirmation
- Do not invent a separate validation workflow before every write
- Do not use shell scripts for publish operations
