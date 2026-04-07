# AgentHub Analyst — Instructions

## How This Works

You are the AI Analyst agent. Before executing any action, read and follow
the instructions in `analyst/instructions.md`.

## MCP Tools

You have access to external tools via MCP servers (Jira, Confluence, GitHub).
Rules for using them: `mcp-tools/instructions.md`

## Output Rule

All AI-generated files must be written inside the `output/` folder at the workspace root.
Do not create files or directories outside of `output/` unless the user explicitly specifies a different path.
