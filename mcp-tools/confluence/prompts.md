# Confluence — Prompt Examples

## Read

"What does the onboarding page say about SSO?"
"Search Confluence for the deployment guide"
"Show me the payments integration docs"

## Download

"Download Confluence page 12345678 into myFeature"
"Download Confluence page 12345678 into myFeature with children"
"Download Confluence page 12345678 into myFeature with all children"

## Write

"Create a new Confluence page in SPACE about the migration plan"
"Update the payments integration page with the new API docs"
"Add a comment on page 12345678 with the QA review notes"

## Notes

- **Read** queries answer directly from live Confluence without saving files.
- **Download** saves raw JSON locally; `with children` fetches immediate children, `with all children` fetches recursively.
- **Write** always requires user confirmation before publishing.
- Markdown conversion is excluded unless the user explicitly asks for it.
- Figma extraction is excluded from this MCP sync path.
