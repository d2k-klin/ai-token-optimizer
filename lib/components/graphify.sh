#!/usr/bin/env bash
# components/graphify.sh — OPTIONAL knowledge-graph repo map.
# Alternative to Codesight (choose ONE). Best for heterogeneous repos: code +
# docs + PDFs + diagrams + cross-language relationships.
# See https://github.com/Graphify-Labs/graphify (PyPI: graphifyy)
#
# NOTE: The PyPI package is "graphifyy" (double y); the CLI is "graphify".
# The npm @sentropic/graphify fork is deprecated (it became the unrelated Engram).

install_graphify() {
  step "Graphify (optional knowledge graph)"
  if [ -d .codesight ] || ls .codesight* >/dev/null 2>&1; then
    warn "Codesight artifacts detected — the spec recommends choosing ONE mapper, not both."
  fi

  local ver="${AITO_GRAPHIFY_VERSION:-latest}"
  local spec="graphifyy"
  [ "$ver" = "latest" ] || spec="graphifyy==$ver"
  info "installing/updating $spec (Python 3.10+)…"
  if have uv; then
    uv tool install --force "$spec" >/dev/null 2>&1
  elif have pipx; then
    pipx install --force "$spec" >/dev/null 2>&1
  else
    warn "uv or pipx not found — install uv from https://docs.astral.sh/uv/, then re-run."
    return 1
  fi
  if ! have graphify; then
    warn "Graphify install failed or is not on PATH (try 'uv tool update-shell')."
    warn "See https://github.com/Graphify-Labs/graphify"
    return 1
  fi
  ok "Graphify ready ($(graphify --version 2>/dev/null || echo "$ver"))"

  # Install the current host skills. `tracks` is dynamically scoped by cmd_setup.
  if printf '%s\n' "${tracks:-}" | grep -Fqx claude; then
    graphify install >/dev/null 2>&1 \
      && ok "installed Graphify skill for Claude Code" \
      || warn "Graphify Claude skill install failed"
  fi
  if printf '%s\n' "${tracks:-}" | grep -Fqx copilot; then
    graphify vscode install >/dev/null 2>&1 \
      && ok "installed Graphify skill for VS Code Copilot" \
      || warn "Graphify Copilot skill install failed"
  fi

  warn "Graphify writes a broad knowledge graph to graphify-out/ — review it before sharing."
  ensure_gitignore "graphify-out/"
  info "Build when needed from your assistant with '/graphify .' (Codex: '\$graphify .')."
}
