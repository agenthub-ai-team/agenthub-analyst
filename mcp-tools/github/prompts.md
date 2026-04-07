# GitHub — Prompt Examples

## Read

"Find PRs related to user authentication"
"What's in the README of auth-service?"
"Search for rate limiting code across our repos"

## Download

### github.com
"Clone git@github.com:ORG/customer-web.git platform web into myFeature"
"Clone git@github.com:ORG/payments-service.git platform backend into myFeature"
"Clone git@github.com:ORG/customer-web.git platform web branch feature-x into myFeature"

### GitHub Enterprise
"Clone git@github.yourcompany.com:ORG/internal-service.git platform backend into myFeature"
"Clone git@github.yourcompany.com:ORG/mobile-app.git platform mobile branch develop into myFeature"

## Write

"Create an issue in ORG/customer-web about the login redirect bug"
"Create a PR from feature-x to main in ORG/auth-service"
"Add a comment on PR #42 in ORG/payments-service saying it's approved"

## Notes

- Always use SSH clone URLs (`git@...`), not HTTPS.
- For github.com repos, use `git@github.com:ORG/REPO.git`.
- For GitHub Enterprise repos, use `git@GITHUB_ENTERPRISE_HOST:ORG/REPO.git` (check `config/.env` for the host).
- Repositories are stored under `documentation/github/[platform]/[repo-name]/`.
- For quick lookups (single files, PR diffs, code search), the GitHub MCP is used directly without cloning.
- Two MCP servers are available: `github` (github.com) and `github-enterprise` (GHE). Use the correct one based on the repo URL.
