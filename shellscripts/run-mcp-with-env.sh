#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/env-loader.sh"

# ---------------------------------------------------------------------------
# Credential guard — silently exit if credentials are still placeholders.
# This prevents Claude Code from spawning MCP servers for unconfigured services
# (which would cause noisy errors in the IDE).
# ---------------------------------------------------------------------------
looks_like_placeholder() {
    local val="${1:-}"
    [[ -z "$val" ]] && return 0
    local upper="${val^^}"
    [[ "$upper" == *YOUR-* || "$upper" == *YOUR_* || "$upper" == *_HERE \
    || "$upper" == *YOURCOMPANY* || "$upper" == *EXAMPLE.COM* \
    || "$upper" == *PLACEHOLDER* || "$upper" == *CHANGEME* \
    || "$upper" == *"TODO"* ]] && return 0
    return 1
}

require_real_credential() {
    local var_name="$1"
    local val="${!var_name:-}"
    if [[ -z "$val" ]] || looks_like_placeholder "$val"; then
        # Silent exit — don't start the MCP server for unconfigured services
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Server launchers
# ---------------------------------------------------------------------------
run_atlassian() {
    load_env_config "jira" --silent
    validate_jira_config --silent
    validate_confluence_config --silent

    require_real_credential "JIRA_URL"
    require_real_credential "JIRA_API_TOKEN"

    export CONFLUENCE_URL
    export CONFLUENCE_USERNAME="$CONFLUENCE_USER"
    export CONFLUENCE_API_TOKEN="$CONFLUENCE_TOKEN"
    export JIRA_URL
    export JIRA_USERNAME="$JIRA_USER"
    export JIRA_API_TOKEN
    export READ_ONLY_MODE="false"

    cd "$ROOT_DIR"
    exec uvx --python 3.13 mcp-atlassian
}

run_github() {
    load_env_config "github" --silent

    require_real_credential "GITHUB_PERSONAL_ACCESS_TOKEN"

    export GITHUB_PERSONAL_ACCESS_TOKEN

    cd "$ROOT_DIR"
    exec github-mcp-server stdio
}

run_github_enterprise() {
    load_env_config "github" --silent

    require_real_credential "GITHUB_ENTERPRISE_PAT"
    require_real_credential "GITHUB_ENTERPRISE_HOST"

    # The Go binary reads GITHUB_PERSONAL_ACCESS_TOKEN and GITHUB_HOST
    export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_ENTERPRISE_PAT"

    # Pass host with scheme — binary requires http(s):// prefix
    local host="${GITHUB_ENTERPRISE_HOST%/}"
    export GITHUB_HOST="$host"

    cd "$ROOT_DIR"
    exec github-mcp-server stdio
}

SERVER_NAME="${1:-}"

case "$SERVER_NAME" in
    atlassian)
        run_atlassian
        ;;
    github)
        run_github
        ;;
    github-enterprise)
        run_github_enterprise
        ;;
    *)
        echo "Usage: $0 {atlassian|github|github-enterprise}" >&2
        exit 1
        ;;
esac
