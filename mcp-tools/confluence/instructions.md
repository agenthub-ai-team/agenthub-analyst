---
name: Confluence
icon: "🔄"
type: tool
description: >
  Read, download, and write Confluence pages through Atlassian MCP.
  Supports live lookups, local JSON sync with child traversal and image downloads,
  and publishing content back to Confluence.
use_when: >
  User wants to read, search, download, or write Confluence content.
  Keywords: "search confluence", "read confluence", "download confluence",
  "create confluence page", "update confluence page", "add confluence comment".
not_when: >
  Request has nothing to do with Confluence.
prompts: "mcp-tools/confluence/prompts.md"
output: "documentation/[feature]/confluence/"
auto_discover: []
---

# Confluence

Read and follow the shared rules in `mcp-tools/instructions.md`.

## Details

- **Source:** Atlassian MCP wired in `.mcp.json` and loading credentials from `config/.env`
- **Prompts:** `mcp-tools/confluence/prompts.md`
- **Default output:** `documentation/[feature]/confluence/`
- **Figma handling:** intentionally excluded from this MCP sync path

## Available Tools

| Tool | Mode | Description |
|------|------|-------------|
| `confluence_search` | Read | Search Confluence pages |
| `confluence_get_page` | Read | Read a specific page |
| `confluence_get_page` + save | Download | Save page JSON locally with recursive child traversal |
| `confluence_create_page` | Write | Create a new Confluence page |
| `confluence_update_page` | Write | Update an existing page |
| `confluence_add_comment` | Write | Add a comment to a page |

## Download

When this tool is selected, the assistant must use Atlassian MCP to save Confluence content locally for offline analysis without generating Markdown unless the user explicitly asks for it.

### 1. Support the same directory modes

Support both directory modes:

- default feature-based output
- custom text directory and custom attachments directory

For the default feature-based output, create:

- `documentation/[feature]/confluence/raw/`
- `documentation/[feature]/attachments/`

If the user explicitly provides custom text or attachments directories, preserve that override behavior:

- `<text-dir>/raw/`
- `<attachments-dir>/`

Do not create `processed/` by default in this MCP sync path.

### 2. Save the same raw page payloads

For every fetched page ID `12345678`, save:

```text
.../raw/page-12345678.json
```

Use this expanded page fetch scope:

```text
/content/{page_id}?expand=body.storage,metadata.labels,version,space,ancestors
```

### 3. Preserve Confluence image download behavior

Extract image references from `body.storage.value` and save them locally.

Handle both:

1. Confluence attachment images referenced through `ri:attachment ri:filename="..."`
2. External `<img src="...">` URLs

Save image files under:

```text
<attachments-dir>/images/
```

Use this filename behavior:

- sanitize attachment filenames with non `[a-zA-Z0-9._-]` characters replaced by `_`
- preserve external image basenames
- if a downloaded image is empty, remove it

### 4. Skip Figma link processing entirely

Do not extract Figma links.
Do not create `<attachments-dir>/figma/`.
Do not invoke any Figma downloader.

### 5. Support the same child traversal modes

Support these three logical modes:

- `none` — fetch only the requested page
- `first` — fetch the requested page plus immediate children
- `all` — fetch the requested page plus all descendants recursively

#### Immediate children mode

When the user requests immediate children, save:

```text
.../raw/page-{page_id}-children.json
```

Fetch children from:

```text
/content/{page_id}/child/page
```

Collect child IDs from `.results[]?.id`, then fetch each child page once.

#### Recursive descendants mode

When the user requests all descendants, save one child-list payload per depth level:

```text
.../raw/page-{page_id}-children-depth-{depth}.json
```

Recurse through `.results[]?.id` until there are no more descendants or depth reaches `10`.

### 6. Avoid duplicate fetch work where possible

The MCP workflow should avoid re-fetching the same page ID unnecessarily within one run when the page hierarchy contains repeated references.

### 7. Preserve the intended Confluence local-sync behavior without Markdown conversion

This tool is successful only if it preserves the intended Confluence local-sync behavior while intentionally omitting the Markdown conversion step:

- raw page JSON
- raw child-list JSON
- downloaded Confluence image attachments
- downloaded external images

Do not create `processed/` markdown files or run validation/regeneration logic for Markdown unless the user explicitly asks for human-readable local docs.

---

## Write

Confluence supports publishing content back through Atlassian MCP. Follow the shared write rules in `mcp-tools/instructions.md`.

### Supported write actions

| Action | MCP tool | When to use |
|--------|----------|-------------|
| Create page | `confluence_create_page` | User wants to publish a new Confluence page from local content |
| Update page | `confluence_update_page` | User wants to update an existing page with new content |
| Add comment | `confluence_add_comment` | User wants to add a comment to an existing page |

### Create a new page

1. Confirm the target **space key** and **parent page** (if nested)
2. Show the user a preview: title, space, parent, and a content summary
3. After approval, call `confluence_create_page` with the page title, space key, parent ID (if any), and body in Confluence storage format
4. Report the new page URL

### Update an existing page

1. Confirm the **page ID** to update — fetch the current version first to show what will change
2. Show a diff summary: what's being added, changed, or removed
3. After approval, call `confluence_update_page` with the page ID, new body, and incremented version number
4. Report the updated page URL

### Content format

- Confluence uses **storage format** (XHTML-like), not markdown
- Convert markdown to storage format before publishing
- Preserve headings, tables, code blocks, and bullet lists in the conversion
- Do not strip images — convert image references to `<ac:image>` tags where possible
