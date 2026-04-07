#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# AgentHub — One-Command Bootstrap
# =============================================================================
# Checks prerequisites, verifies config files exist, creates required
# directories, generates IDE-specific MCP configs, and reports readiness.
#
# Usage:
#   ./setup.sh              Full bootstrap
#   ./setup.sh --check      Prerequisites check only (no file changes)
#
# After running this, paste the setup wizard prompt into your AI assistant
# to complete the interactive credential setup. See guides/onboarding.md.
# =============================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

MODE="full"
ERRORS=0

# ---------------------------------------------------------------------------
# OS Detection
# ---------------------------------------------------------------------------
case "$(uname -s)" in
    Darwin*)  OS_TYPE="macos" ;;
    Linux*)   OS_TYPE="linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE="windows" ;;
    *)        OS_TYPE="unknown" ;;
esac

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
step()  { echo -e "\n${BLUE}▶${NC} ${BOLD}$1${NC}"; }
ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
fail()  { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }
info()  { echo -e "  ${BLUE}·${NC} $1"; }

ask_install() {
    local name="$1"
    echo -en "  ${YELLOW}?${NC} $name is missing. Install it now? [Y/n] "
    read -r answer </dev/tty
    [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
}

install_pkg() {
    local brew_pkg="$1"
    local apt_pkg="$2"
    local winget_pkg="$3"
    local choco_pkg="$4"
    case "$INSTALLER" in
        brew)   brew install "$brew_pkg" ;;
        apt)    sudo apt-get install -y "$apt_pkg" ;;
        winget) winget install --accept-package-agreements --accept-source-agreements "$winget_pkg" ;;
        choco)  choco install -y "$choco_pkg" ;;
    esac
}

install_hint() {
    local name="$1"
    local brew_cmd="${2:-}"
    local apt_cmd="${3:-}"
    local win_cmd="${4:-}"
    case "$OS_TYPE" in
        macos)   [[ -n "$brew_cmd" ]] && info "Install: $brew_cmd" ;;
        linux)   [[ -n "$apt_cmd" ]]  && info "Install: $apt_cmd" ;;
        windows) [[ -n "$win_cmd" ]]  && info "Install: $win_cmd" ;;
        *)       info "Install $name per your OS instructions" ;;
    esac
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)  MODE="check" ;;
        -h|--help)
            echo "Usage: ./setup.sh [--check]"
            echo ""
            echo "  (no flag)   Full bootstrap — check prerequisites + verify config"
            echo "  --check     Only check prerequisites, don't modify anything"
            echo ""
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

echo -e "${BOLD}AgentHub — Setup${NC}"
echo "─────────────────────────────────────"
info "OS: $OS_TYPE"

# ---------------------------------------------------------------------------
# Detect package manager
# ---------------------------------------------------------------------------
INSTALLER=""
if command -v brew >/dev/null 2>&1; then
    INSTALLER="brew"
elif command -v apt-get >/dev/null 2>&1; then
    INSTALLER="apt"
elif command -v winget >/dev/null 2>&1; then
    INSTALLER="winget"
elif command -v choco >/dev/null 2>&1; then
    INSTALLER="choco"
fi

# ---------------------------------------------------------------------------
# 1. Check prerequisites — auto-install if missing
# ---------------------------------------------------------------------------
step "Checking prerequisites"

# Node.js >= 18
if command -v node >/dev/null 2>&1; then
    NODE_VER="$(node --version | sed 's/^v//')"
    NODE_MAJOR="${NODE_VER%%.*}"
    if [[ "$NODE_MAJOR" -ge 18 ]]; then
        ok "Node.js $NODE_VER (>= 18 required)"
    else
        warn "Node.js $NODE_VER is too old (>= 18 required)"
        if [[ -n "$INSTALLER" ]] && ask_install "Node.js"; then
            echo -e "  ${BLUE}·${NC} Installing Node.js..."
            install_pkg "node" "nodejs" "OpenJS.NodeJS.LTS" "nodejs-lts"
            ok "Node.js installed ($(node --version))"
        else
            fail "Node.js >= 18 is required"
            install_hint "Node.js" "brew install node" "sudo apt install nodejs" "winget install OpenJS.NodeJS.LTS"
        fi
    fi
else
    if [[ -n "$INSTALLER" ]] && ask_install "Node.js"; then
        echo -e "  ${BLUE}·${NC} Installing Node.js..."
        install_pkg "node" "nodejs" "OpenJS.NodeJS.LTS" "nodejs-lts"
        ok "Node.js installed ($(node --version))"
    else
        fail "Node.js is not installed (>= 18 required)"
        install_hint "Node.js" "brew install node" "sudo apt install nodejs" "winget install OpenJS.NodeJS.LTS"
    fi
fi

# npm / npx
if command -v npx >/dev/null 2>&1; then
    ok "npx is available"
else
    fail "npx is not available (comes with Node.js)"
fi

# Python >= 3.11
if command -v python3 >/dev/null 2>&1; then
    PY_VER="$(python3 --version 2>&1 | sed 's/Python //')"
    PY_MAJOR="$(echo "$PY_VER" | cut -d. -f1)"
    PY_MINOR="$(echo "$PY_VER" | cut -d. -f2)"
    if [[ "$PY_MAJOR" -ge 3 && "$PY_MINOR" -ge 11 ]]; then
        ok "Python $PY_VER (>= 3.11 required)"
    else
        warn "Python $PY_VER is too old (>= 3.11 required)"
        if [[ -n "$INSTALLER" ]] && ask_install "Python 3.11+"; then
            echo -e "  ${BLUE}·${NC} Installing Python..."
            install_pkg "python" "python3" "Python.Python.3.12" "python3"
            ok "Python installed ($(python3 --version))"
        else
            fail "Python >= 3.11 is required"
            install_hint "Python" "brew install python" "sudo apt install python3" "winget install Python.Python.3.12"
        fi
    fi
else
    if [[ -n "$INSTALLER" ]] && ask_install "Python 3"; then
        echo -e "  ${BLUE}·${NC} Installing Python..."
        install_pkg "python" "python3" "Python.Python.3.12" "python3"
        ok "Python installed ($(python3 --version))"
    else
        fail "Python 3 is not installed (>= 3.11 required)"
        install_hint "Python" "brew install python" "sudo apt install python3" "winget install Python.Python.3.12"
    fi
fi

# uv (Python package runner)
if command -v uv >/dev/null 2>&1; then
    ok "uv is available ($(uv --version 2>/dev/null || echo 'unknown version'))"
elif command -v uvx >/dev/null 2>&1; then
    ok "uvx is available"
else
    if ask_install "uv"; then
        echo -e "  ${BLUE}·${NC} Installing uv..."
        if [[ "$OS_TYPE" == "windows" ]]; then
            powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex" || true
        else
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
        ok "uv installed"
    else
        fail "uv is not installed (needed for Atlassian MCP server)"
        install_hint "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh" "curl -LsSf https://astral.sh/uv/install.sh | sh" "powershell -c 'irm https://astral.sh/uv/install.ps1 | iex'"
    fi
fi

# git
if command -v git >/dev/null 2>&1; then
    ok "git is available ($(git --version | sed 's/git version //'))"
else
    if [[ -n "$INSTALLER" ]] && ask_install "git"; then
        echo -e "  ${BLUE}·${NC} Installing git..."
        install_pkg "git" "git" "Git.Git" "git"
        ok "git installed"
    else
        fail "git is not installed"
    fi
fi

# SSH key (for GitHub clone)
if [[ -f "$HOME/.ssh/id_rsa" || -f "$HOME/.ssh/id_ed25519" || -f "$HOME/.ssh/id_ecdsa" ]]; then
    ok "SSH key found (for GitHub clone via SSH)"
else
    warn "No SSH key found — GitHub clone via SSH may not work"
    info "Generate: ssh-keygen -t ed25519 -C your.email@company.com"
fi

# Copilot CLI (GitHub's terminal AI agent — needed for MCP outside Claude Code)
COPILOT_MIN_VERSION="1.0.14"

version_gte() {
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]
}

if command -v copilot >/dev/null 2>&1; then
    COPILOT_VER="$(copilot --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "0.0.0")"
    if version_gte "$COPILOT_VER" "$COPILOT_MIN_VERSION"; then
        ok "copilot-cli $COPILOT_VER (>= $COPILOT_MIN_VERSION required for MCP)"
    else
        warn "copilot-cli $COPILOT_VER is below minimum $COPILOT_MIN_VERSION (MCP support)"
        if ask_install "copilot-cli upgrade"; then
            echo -e "  ${BLUE}·${NC} Upgrading copilot-cli..."
            case "$OS_TYPE" in
                macos)   brew upgrade copilot-cli 2>/dev/null || brew install copilot-cli ;;
                linux)   curl -fsSL https://gh.io/copilot-install | bash ;;
                windows) winget install --accept-package-agreements --accept-source-agreements GitHub.Copilot ;;
            esac
            ok "copilot-cli upgraded"
        else
            warn "copilot-cli $COPILOT_VER may not support MCP — upgrade recommended"
        fi
    fi
else
    if ask_install "copilot-cli (GitHub Copilot terminal agent)"; then
        echo -e "  ${BLUE}·${NC} Installing copilot-cli..."
        case "$OS_TYPE" in
            macos)   brew install copilot-cli ;;
            linux)   curl -fsSL https://gh.io/copilot-install | bash ;;
            windows) winget install --accept-package-agreements --accept-source-agreements GitHub.Copilot ;;
        esac
        if command -v copilot >/dev/null 2>&1; then
            ok "copilot-cli installed ($(copilot --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1))"
        else
            warn "copilot-cli installed — restart terminal to use it"
        fi
    else
        info "copilot-cli not installed — skip if you only use Claude Code"
        install_hint "copilot-cli" "brew install copilot-cli" "curl -fsSL https://gh.io/copilot-install | bash" "winget install GitHub.Copilot"
    fi
fi

if [[ "$MODE" == "check" ]]; then
    echo ""
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Prerequisites check: $ERRORS issue(s) found${NC}"
        exit 1
    else
        echo -e "${GREEN}All prerequisites met.${NC}"
        exit 0
    fi
fi

# ---------------------------------------------------------------------------
# 2. Verify configuration files
# ---------------------------------------------------------------------------
step "Checking configuration files"

# config/.env — committed with placeholder values, user fills in real credentials
if [[ -f "$ROOT_DIR/config/.env" ]]; then
    ok "config/.env exists"
else
    fail "config/.env is missing — it should be part of the repo. Try: git checkout config/.env"
fi

# ---------------------------------------------------------------------------
# 3. Create required directories
# ---------------------------------------------------------------------------
step "Creating workspace directories"

for dir in documentation output; do
    if [[ ! -d "$ROOT_DIR/$dir" ]]; then
        mkdir -p "$ROOT_DIR/$dir"
        ok "Created $dir/"
    else
        ok "$dir/ already exists"
    fi
done

# ---------------------------------------------------------------------------
# 4. Generate .mcp.json from configured credentials
# ---------------------------------------------------------------------------
step "Generating MCP server config from credentials"

generate_mcp_json() {
    local env_file="$ROOT_DIR/config/.env"
    [[ -f "$env_file" ]] || { fail "config/.env not found — cannot generate .mcp.json"; return 1; }

    # Source the env file to get variable values
    set +u  # allow unset vars during source
    source "$env_file" 2>/dev/null || true
    set -u

    # Reuse the same placeholder detection from run-mcp-with-env.sh
    _is_real() {
        local val="${1:-}"
        [[ -z "$val" ]] && return 1
        local upper
        upper="$(echo "$val" | tr '[:lower:]' '[:upper:]')"
        [[ "$upper" == *YOUR-* || "$upper" == *YOUR_* || "$upper" == *_HERE \
        || "$upper" == *YOURCOMPANY* || "$upper" == *EXAMPLE.COM* \
        || "$upper" == *PLACEHOLDER* || "$upper" == *CHANGEME* \
        || "$upper" == *"TODO"* ]] && return 1
        return 0
    }

    local enabled=()
    local skipped=()

    # Check each service — same credential vars that run-mcp-with-env.sh checks
    if _is_real "${JIRA_API_TOKEN:-}" || _is_real "${CONFLUENCE_TOKEN:-}"; then
        enabled+=("atlassian")
    else
        skipped+=("Atlassian (Jira + Confluence)")
    fi

    if _is_real "${GITHUB_PERSONAL_ACCESS_TOKEN:-}"; then
        enabled+=("github")
    else
        skipped+=("GitHub")
    fi

    if _is_real "${GITHUB_ENTERPRISE_PAT:-}" && _is_real "${GITHUB_ENTERPRISE_HOST:-}"; then
        enabled+=("github-enterprise")
    else
        skipped+=("GitHub Enterprise")
    fi

    # Build .mcp.json with only enabled servers
    local mcp_file="$ROOT_DIR/.mcp.json"
    local first=true

    echo '{' > "$mcp_file"
    echo '  "mcpServers": {' >> "$mcp_file"

    for server in "${enabled[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ',' >> "$mcp_file"
        fi
        # Write server entry (no trailing newline so comma logic works)
        printf '    "%s": {\n      "command": "bash",\n      "args": ["shellscripts/run-mcp-with-env.sh", "%s"]\n    }' "$server" "$server" >> "$mcp_file"
    done

    echo '' >> "$mcp_file"
    echo '  }' >> "$mcp_file"
    echo '}' >> "$mcp_file"

    # Report results
    for s in "${enabled[@]}"; do
        ok "Enabled: $s"
    done
    for s in "${skipped[@]}"; do
        info "Skipped: $s (no credentials in config/.env)"
    done

    if [[ ${#enabled[@]} -eq 0 ]]; then
        warn "No MCP servers enabled — fill in credentials in config/.env and re-run ./setup.sh"
    else
        ok "Generated .mcp.json with ${#enabled[@]} server(s)"
    fi
}

generate_mcp_json

# ---------------------------------------------------------------------------
# 5. IDE & AI tool detection + MCP config generation
# ---------------------------------------------------------------------------
step "Detecting IDE"

ACTIVE_IDE=""

# Only check env vars that prove we're running INSIDE this IDE's terminal right now.
# Order matters: more specific checks first (Cursor sets VSCODE_PID too).
if [[ -n "${CURSOR_TRACE_ID:-}" ]]; then
    ACTIVE_IDE="Cursor"
    # Cursor needs .mcp.json copied into .cursor/
    if [[ ! -f "$ROOT_DIR/.cursor/mcp.json" ]]; then
        mkdir -p "$ROOT_DIR/.cursor"
        cp "$ROOT_DIR/.mcp.json" "$ROOT_DIR/.cursor/mcp.json"
        ok "Cursor — copied .mcp.json to .cursor/mcp.json"
    else
        ok "Cursor"
    fi
elif [[ -n "${VSCODE_PID:-}" ]]; then
    ACTIVE_IDE="VS Code"
    ok "VS Code"
elif [[ -n "${JETBRAINS_IDE:-}" || -n "${IDEA_INITIAL_DIRECTORY:-}" || "${TERMINAL_EMULATOR:-}" == *JetBrains* ]]; then
    ACTIVE_IDE="JetBrains"
    ok "JetBrains IDE (${JETBRAINS_IDE:-detected via terminal})"
else
    info "No active IDE detected in this terminal session."
fi

# Generate VS Code MCP config (transforms mcpServers → servers)
generate_vscode_mcp() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json, sys
with open('$ROOT_DIR/.mcp.json') as f:
    data = json.load(f)
servers = data.get('mcpServers', {})
out = {'servers': servers}
with open('$ROOT_DIR/.vscode/mcp.json', 'w') as f:
    json.dump(out, f, indent=2)
" 2>/dev/null && return 0
    fi
    return 1
}

if [[ "$ACTIVE_IDE" == "VS Code" ]]; then
    mkdir -p "$ROOT_DIR/.vscode"
    if generate_vscode_mcp; then
        ok "$ACTIVE_IDE — generated .vscode/mcp.json (servers format)"
    else
        warn "$ACTIVE_IDE — could not generate .vscode/mcp.json (python3 needed)"
    fi
fi

step "Detecting AI tool"

ACTIVE_AI=""

generate_copilot_cli_mcp() {
    # Copilot CLI reads ~/.copilot/mcp-config.json with a different schema:
    #   - "type": "stdio" required
    #   - "tools": ["*"] required
    #   - "env": {} required (can be empty)
    #   - paths must be absolute (Copilot CLI doesn't resolve relative to project root)
    local copilot_dir="$HOME/.copilot"
    local dst="$copilot_dir/mcp-config.json"
    mkdir -p "$copilot_dir"
    python3 - "$ROOT_DIR/.mcp.json" "$dst" "$ROOT_DIR" <<'PY'
import json, sys, os

src, dst, root = sys.argv[1], sys.argv[2], sys.argv[3]
with open(src) as f:
    data = json.load(f)

servers = data.get("mcpServers", data.get("servers", {}))
copilot_servers = {}

for name, cfg in servers.items():
    new_cfg = {
        "type": "stdio",
        "command": cfg.get("command", ""),
        "args": [],
        "env": cfg.get("env", {}),
        "tools": ["*"]
    }
    # Convert relative paths in args to absolute
    for arg in cfg.get("args", []):
        if not os.path.isabs(arg) and not arg.startswith("-"):
            abs_path = os.path.join(root, arg)
            if os.path.exists(abs_path):
                new_cfg["args"].append(abs_path)
            else:
                new_cfg["args"].append(arg)
        else:
            new_cfg["args"].append(arg)
    copilot_servers[name] = new_cfg

with open(dst, "w") as f:
    json.dump({"mcpServers": copilot_servers}, f, indent=2)
    f.write("\n")
PY
}

if [[ -n "${CLAUDECODE:-}" || -n "${CLAUDE_CODE:-}" ]]; then
    ACTIVE_AI="Claude Code"
    ok "Claude Code — .mcp.json in project root is used automatically"
elif [[ -n "${CURSOR_TRACE_ID:-}" ]]; then
    ACTIVE_AI="Cursor"
    ok "Cursor — .cursor/mcp.json is used automatically"
elif [[ -n "${COPILOT_CLI:-}" || -n "${GITHUB_COPILOT:-}" || -n "${COPILOT_AGENT:-}" ]]; then
    ACTIVE_AI="Copilot CLI"
    generate_copilot_cli_mcp && ok "Copilot CLI — generated ~/.copilot/mcp-config.json from .mcp.json" || warn "Copilot CLI — failed to generate ~/.copilot/mcp-config.json"
else
    info "No active AI tool detected in this terminal session."
    info "Claude Code reads .mcp.json natively — no extra config needed."
    if [[ -f "$ROOT_DIR/.mcp.json" ]]; then
        generate_copilot_cli_mcp && ok "Generated ~/.copilot/mcp-config.json for Copilot CLI use" || warn "Failed to generate ~/.copilot/mcp-config.json"
    fi
fi

# ---------------------------------------------------------------------------
# 6. Dynamic config/.env scan — report credential status
# ---------------------------------------------------------------------------
step "Checking credential readiness"

NEEDS_CREDS=false

# Parse group headers from config/.env (format: "# --- GroupName ---")
# and check if the variables under each group are configured.
scan_env_groups() {
    local env_file="$ROOT_DIR/config/.env"
    [[ -f "$env_file" ]] || return

    local current_group=""
    local group_has_configured=false
    local group_has_placeholder=false
    local group_has_commented=false
    local group_has_any_var=false

    emit_group() {
        [[ -z "$current_group" ]] && return
        if [[ "$group_has_configured" == "true" && "$group_has_placeholder" == "false" ]]; then
            ok "$current_group — configured"
        elif [[ "$group_has_placeholder" == "true" ]]; then
            warn "$current_group — has placeholder values (replace with real credentials)"
            NEEDS_CREDS=true
        elif [[ "$group_has_commented" == "true" ]]; then
            warn "$current_group — found but commented out (uncomment and fill in to enable)"
            NEEDS_CREDS=true
        elif [[ "$group_has_any_var" == "false" ]]; then
            # Group header with no variables under it — skip silently
            :
        else
            info "$current_group — not found"
        fi
    }

    while IFS= read -r line; do
        # Detect group headers: "# --- GroupName ---" or "# --- GroupName (SubName) ---"
        if [[ "$line" =~ ^#[[:space:]]*---[[:space:]]*(.+)[[:space:]]*---[[:space:]]*$ ]]; then
            emit_group
            current_group="${BASH_REMATCH[1]}"
            current_group="${current_group## }"  # trim leading
            current_group="${current_group%% }"  # trim trailing
            group_has_configured=false
            group_has_placeholder=false
            group_has_commented=false
            group_has_any_var=false
            continue
        fi

        # Skip non-variable lines
        [[ -z "$line" || "$line" =~ ^#[[:space:]]*[A-Z] && ! "$line" =~ ^#[[:space:]]*(export[[:space:]]+)?[A-Z_]+= ]] && continue

        # Check for commented-out variable: "# VAR=..." or "# export VAR=..."
        if [[ "$line" =~ ^#[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)= ]]; then
            group_has_any_var=true
            group_has_commented=true
            continue
        fi

        # Check for active variable: "VAR=..." or "export VAR=..."
        if [[ "$line" =~ ^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            group_has_any_var=true
            local value="${BASH_REMATCH[3]}"
            value="${value%\"}"   # strip trailing quote
            value="${value#\"}"   # strip leading quote
            value="${value%\'}"
            value="${value#\'}"
            local upper
            upper="$(echo "$value" | tr '[:lower:]' '[:upper:]')"

            if [[ -z "$value" || "$upper" == *YOUR_* || "$upper" == *_HERE || "$upper" == *YOURCOMPANY* || "$upper" == *EXAMPLE.COM* || "$upper" == *YOUR-* ]]; then
                group_has_placeholder=true
            else
                group_has_configured=true
            fi
        fi
    done < "$env_file"

    # Emit the last group
    emit_group
}

scan_env_groups

# ---------------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------------
echo ""
echo "─────────────────────────────────────"

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Setup completed with $ERRORS prerequisite issue(s).${NC}"
    echo "Fix the issues above, then re-run: ./setup.sh"
    exit 1
fi

if [[ "$NEEDS_CREDS" == "true" ]]; then
    echo -e "${GREEN}Bootstrap complete!${NC} Config files are ready."
    echo ""
    echo -e "${BOLD}Next step — fill in your credentials:${NC}"
    echo ""
    echo "  Option A: Edit config/.env manually"
    echo "  Option B: Paste this into your AI assistant for guided setup:"
    echo ""
    echo -e "    ${BLUE}Set up my project. Follow guides/setup-wizard.md${NC}"
    echo ""
else
    echo -e "${GREEN}Setup complete! All credentials are configured.${NC}"
    echo ""
    echo "Restart your IDE / AI tool, then verify by asking your AI assistant:"
    echo ""
    echo -e "  ${BLUE}Is my setup OK?${NC}"
fi
