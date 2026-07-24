#!/usr/bin/env bash
# components/openwiki.sh — install OpenWiki, a maintained codebase wiki for agents.
# Requires Node >=22/npm. Initial provider/model configuration remains interactive,
# so aito installs the CLI and tells the user how to initialize it.
# Override version with AITO_OPENWIKI_VERSION (default: latest).

install_openwiki() {
  step "OpenWiki (agent documentation)"
  if ! have npm; then
    warn "npm not found — install Node.js, then re-run. Skipping OpenWiki."
    return 1
  fi
  if ! node_at_least 22; then
    warn "OpenWiki requires Node.js >=22. Upgrade Node, then re-run."
    return 1
  fi

  local ver="${AITO_OPENWIKI_VERSION:-latest}"
  info "installing/updating openwiki@$ver (global, npm)…"
  if npm install -g "openwiki@$ver" >/dev/null 2>&1 && have openwiki; then
    ok "OpenWiki ready ($(OPENWIKI_TELEMETRY_DISABLED=1 openwiki --version 2>/dev/null || echo "$ver"))"
  elif have openwiki; then
    warn "OpenWiki update failed; continuing with the existing binary"
  else
    warn "OpenWiki install failed — see https://github.com/langchain-ai/openwiki"
    return 1
  fi

  info "First use: OPENWIKI_TELEMETRY_DISABLED=1 openwiki --init"
  info "OpenWiki will ask for an inference provider, model, and API key."

  warn "The optional workflow sends repository context to that provider on a schedule"
  warn "and needs GitHub contents/pull-request write permissions."
  if confirm "Also add a GitHub Action for automatic OpenWiki documentation updates?" n; then
    local workflow=".github/workflows/openwiki-update.yml"
    if [ -f "$workflow" ]; then
      info "workflow already exists; left unchanged: $workflow"
    else
      render_template "$AITO_TEMPLATES/openwiki/openwiki-update.yml" "$workflow"
    fi
    warn "Before enabling the workflow, review its schedule/model and add OPENROUTER_API_KEY"
    warn "as a GitHub Actions secret (or replace the provider configuration)."
  else
    info "GitHub Action not added (you can opt in on a later 'aito setup' run)."
  fi
}
