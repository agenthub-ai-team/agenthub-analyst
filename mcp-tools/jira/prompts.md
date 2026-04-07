# Jira — Prompt Examples

## Read

"What's the status of PROJ-123?"
"Show me all open bugs in project MOBILE"
"Who is assigned to PROJ-456?"

## Download

"Download Jira ticket PROJ-123 into myFeature"
"Download Jira epic PROJ-500 into myFeature with depth 2"
"Download Jira epic PROJ-500 into myFeature with recursive traversal depth 2 and save JSON only"

## Write

"Create a bug ticket in PROJ for the login redirect issue"
"Add a comment on PROJ-123 saying it's ready for QA"
"Move PROJ-456 to In Review"

## Notes

- Default depth is `0`, which downloads only the requested issue.
- The saved output should include raw JSON artifacts, child/linked traversal, and attachments.
- Markdown conversion is intentionally excluded unless the user explicitly asks for it.
