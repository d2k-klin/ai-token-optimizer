#!/usr/bin/env bash
# components/ccusage.sh — install ccusage, a local token-usage & cost tracker.
# Reads usage logs that coding-agent CLIs write locally (Claude Code at
# ~/.claude/projects/, GitHub Copilot CLI, Codex, Gemini CLI, …) and reports
# daily/weekly/monthly/session token + cost totals. Local-only, nothing uploaded.
# It is how you watch token usage trend DOWN after applying the other tools.
# See https://github.com/ccusage/ccusage — override with AITO_CCUSAGE_VERSION.
# (The project moved from github.com/ryoppippi/ccusage to its own org as of v20.)

install_ccusage() {
  step "ccusage (token-usage monitor)"
  if ! have npx; then
    warn "npx (Node.js) not found — install Node.js to use ccusage. Skipping."
    return 1
  fi
  local ver="${AITO_CCUSAGE_VERSION:-latest}"

  if have ccusage; then
    ok "ccusage already on PATH"
  else
    info "installing ccusage@$ver (global, npm)…"
    if npm install -g "ccusage@$ver" >/dev/null 2>&1; then
      ok "installed ccusage@$ver"
    else
      warn "global install failed — you can still run it on demand: npx ccusage@$ver"
    fi
  fi

  info "Usage:  ccusage            # daily token + cost report"
  info "        ccusage monthly    # monthly totals"
  info "Local-only: it reads agent logs on this machine and uploads nothing."
}
