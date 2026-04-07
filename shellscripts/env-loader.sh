#!/bin/bash

# Environment Configuration Loader for AgentHub
# This script provides centralized loading of environment configurations for all sources

# Get the script directory and config path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if silent mode is enabled
is_silent_mode() {
    [[ "${SILENT_ENV:-false}" == "true" ]] || [[ "${1:-}" == "--silent" ]]
}

# Silent-aware print functions
print_env_info() {
    local message="$1"
    local silent_flag="${2:-}"
    if ! is_silent_mode "$silent_flag"; then
        echo -e "${GREEN}[ENV]${NC} $message" >&2
    fi
}

print_env_warning() {
    local message="$1"
    local silent_flag="${2:-}"
    if ! is_silent_mode "$silent_flag"; then
        echo -e "${YELLOW}[ENV]${NC} $message" >&2
    fi
}

print_env_error() {
    local message="$1"
    local silent_flag="${2:-}"
    if ! is_silent_mode "$silent_flag"; then
        echo -e "${RED}[ENV]${NC} $message" >&2
    fi
}

print_env_step() {
    local message="$1"
    local silent_flag="${2:-}"
    if ! is_silent_mode "$silent_flag"; then
        echo -e "${BLUE}[ENV]${NC} $message" >&2
    fi
}

# Function to load environment configuration for a specific source
load_env_config() {
    local source_type="$1"
    local silent_flag="${2:-}"

    if [[ -z "$source_type" ]]; then
        print_env_error "Error: Source type is required (jira, confluence, github)" "$silent_flag"
        return 1
    fi

    # Use the main .env file for all configurations
    local env_file="$CONFIG_DIR/.env"

    # Check if main env file exists
    if [[ -f "$env_file" ]]; then
        print_env_info "Loading $source_type configuration from: $env_file" "$silent_flag"
        source "$env_file"
        return 0
    fi

    # No env file found
    print_env_error "No configuration file found at: $env_file" "$silent_flag"
    print_env_error "Please create $env_file with your credentials" "$silent_flag"
    return 1
}

# Function to validate required environment variables for Jira
validate_jira_config() {
    local silent_flag="${1:-}"
    local missing_vars=()

    [[ -z "$JIRA_URL" ]] && missing_vars+=("JIRA_URL")
    [[ -z "$JIRA_USER" ]] && missing_vars+=("JIRA_USER")
    [[ -z "$JIRA_API_TOKEN" ]] && missing_vars+=("JIRA_API_TOKEN")

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_env_error "Missing required Jira variables: ${missing_vars[*]}" "$silent_flag"
        return 1
    fi

    print_env_info "Jira configuration validated" "$silent_flag"
    return 0
}

# Function to validate required environment variables for Confluence
validate_confluence_config() {
    local silent_flag="${1:-}"
    local missing_vars=()

    [[ -z "$CONFLUENCE_URL" ]] && missing_vars+=("CONFLUENCE_URL")
    [[ -z "$CONFLUENCE_USER" ]] && missing_vars+=("CONFLUENCE_USER")
    [[ -z "$CONFLUENCE_TOKEN" ]] && missing_vars+=("CONFLUENCE_TOKEN")

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_env_error "Missing required Confluence variables: ${missing_vars[*]}" "$silent_flag"
        return 1
    fi

    print_env_info "Confluence configuration validated" "$silent_flag"
    return 0
}

# Function to validate required environment variables for GitHub (github.com)
validate_github_config() {
    local silent_flag="${1:-}"
    local missing_vars=()

    [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]] && missing_vars+=("GITHUB_PERSONAL_ACCESS_TOKEN")

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_env_error "Missing required GitHub variables: ${missing_vars[*]}" "$silent_flag"
        return 1
    fi

    print_env_info "GitHub configuration validated" "$silent_flag"
    return 0
}

# Function to validate required environment variables for GitHub Enterprise
validate_github_enterprise_config() {
    local silent_flag="${1:-}"
    local missing_vars=()

    [[ -z "${GITHUB_ENTERPRISE_HOST:-}" ]] && missing_vars+=("GITHUB_ENTERPRISE_HOST")
    [[ -z "${GITHUB_ENTERPRISE_PAT:-}" ]] && missing_vars+=("GITHUB_ENTERPRISE_PAT")

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_env_error "Missing required GitHub Enterprise variables: ${missing_vars[*]}" "$silent_flag"
        return 1
    fi

    print_env_info "GitHub Enterprise configuration validated" "$silent_flag"
    return 0
}

# Convenience functions for loading and validating specific configurations
load_jira_config() {
    local silent_flag="${1:-}"
    load_env_config "jira" "$silent_flag" && validate_jira_config "$silent_flag"
}

load_confluence_config() {
    local silent_flag="${1:-}"
    load_env_config "confluence" "$silent_flag" && validate_confluence_config "$silent_flag"
}

load_github_config() {
    local silent_flag="${1:-}"
    load_env_config "github" "$silent_flag" && validate_github_config "$silent_flag"
}

load_github_enterprise_config() {
    local silent_flag="${1:-}"
    load_env_config "github" "$silent_flag" && validate_github_enterprise_config "$silent_flag"
}

# Function to show available configurations
show_available_configs() {
    echo -e "${BLUE}[ENV]${NC} Available configuration types:"
    echo "  - jira       (Jira issue tracking)"
    echo "  - confluence (Confluence documentation)"
    echo "  - github     (GitHub repositories — github.com)"
    echo "  - github-enterprise (GitHub Enterprise)"
    echo ""
    echo -e "${BLUE}[ENV]${NC} Configuration file: $CONFIG_DIR/.env"
}

# Export functions for use in other scripts
export -f load_env_config
export -f validate_jira_config
export -f validate_confluence_config
export -f validate_github_config
export -f validate_github_enterprise_config
export -f load_jira_config
export -f load_confluence_config
export -f load_github_config
export -f load_github_enterprise_config
export -f show_available_configs

# Command line interface
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "load")
            if [[ -n "$2" ]]; then
                load_env_config "$2"
            else
                echo "Usage: $0 load <source_type>"
                echo "Available sources: jira, confluence, github, github-enterprise"
            fi
            ;;
        "validate")
            case "$2" in
                "jira") load_jira_config ;;
                "confluence") load_confluence_config ;;
                "github") load_github_config ;;
                "github-enterprise") load_github_enterprise_config ;;
                *)
                    echo "Usage: $0 validate <source_type>"
                    echo "Available sources: jira, confluence, github, github-enterprise"
                    ;;
            esac
            ;;
        "list")
            show_available_configs
            ;;
        "-h"|"--help"|"")
            echo "Environment Configuration Loader for AgentHub"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  load <source>     - Load environment configuration for source"
            echo "  validate <source> - Load and validate required variables"
            echo "  list             - Show available configurations"
            echo ""
            echo "Sources: jira, confluence, github, github-enterprise"
            echo ""
            echo "Examples:"
            echo "  $0 load jira"
            echo "  $0 validate jira"
            echo "  $0 list"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use $0 --help for usage information"
            exit 1
            ;;
    esac
fi
