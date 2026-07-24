#!/usr/bin/env bash
# components/graphify.sh — OPTIONAL knowledge-graph repo map.
# Alternative to Codesight (choose ONE). Best for heterogeneous repos: code +
# docs + PDFs + diagrams + cross-language relationships.
# See https://github.com/rhanka/graphify (npm: @sentropic/graphify)
#
# NOTE: The npm "graphify" package is an unrelated jQuery graph library.
# The correct package is @sentropic/graphify.

install_graphify() {
  step "Graphify (optional knowledge graph)"
  if [ -d .codesight ] || ls .codesight* >/dev/null 2>&1; then
    warn "Codesight artifacts detected — the spec recommends choosing ONE mapper, not both."
  fi
  if ! have npm; then warn "npm (Node.js) not found — skipping Graphify."; return 1; fi
  if ! node_at_least 20; then warn "Graphify requires Node.js >=20."; return 1; fi

  local pkg="@sentropic/graphify"
  local ver="${AITO_GRAPHIFY_VERSION:-latest}"
  info "installing/updating $pkg@$ver (global, npm)…"
  if npm install -g "$pkg@$ver" >/dev/null 2>&1 && have graphify; then
    ok "Graphify ready ($(graphify --version 2>/dev/null || echo "$ver"))"
  elif have graphify; then
    warn "Graphify update failed; continuing with the existing binary"
  else
    warn "Graphify install failed — see https://github.com/rhanka/graphify"
    return 1
  fi

  # Install the current host skills. `tracks` is dynamically scoped by cmd_setup.
  if printf '%s\n' "${tracks:-}" | grep -Fqx claude; then
    graphify install --platform claude >/dev/null 2>&1 \
      && ok "installed Graphify skill for Claude Code" \
      || warn "Graphify Claude skill install failed"
  fi
  if printf '%s\n' "${tracks:-}" | grep -Fqx copilot; then
    graphify install --platform vscode >/dev/null 2>&1 \
      && ok "installed Graphify skill for VS Code Copilot" \
      || warn "Graphify Copilot skill install failed"
  fi

  warn "Graphify writes a broad knowledge graph to .graphify/ — review it before sharing."
  ensure_gitignore ".graphify/" "graphify-out/"
  info "Build when needed from your assistant with '/graphify .' (Codex: '\$graphify .')."
}
