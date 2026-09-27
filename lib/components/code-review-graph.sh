#!/usr/bin/env bash
# components/code-review-graph.sh — OPTIONAL review-scoped code graph over MCP.
# Tree-sitter graph in local SQLite; answers "what does this diff touch?" so
# reviews read the blast radius instead of whole files. No telemetry; cloud
# embeddings are opt-in. Agent configuration stays behind a confirmation.
# See https://github.com/tirth8205/code-review-graph (PyPI: code-review-graph)

install_code_review_graph() {
  step "code-review-graph (optional review context)"
  local ver="${AITO_CODE_REVIEW_GRAPH_VERSION:-latest}"
  local spec="code-review-graph"
  [ "$ver" = "latest" ] || spec="code-review-graph==$ver"
  info "installing/updating $spec (Python 3.10+)…"
  if have uv; then
    uv tool install --force "$spec" >/dev/null 2>&1
  elif have pipx; then
    pipx install --force "$spec" >/dev/null 2>&1
  else
    warn "uv or pipx not found — install uv from https://docs.astral.sh/uv/, then re-run."
    return 1
  fi
  if ! have code-review-graph; then
    warn "code-review-graph install failed — see https://github.com/tirth8205/code-review-graph"
    return 1
  fi
  ok "code-review-graph ready ($(code-review-graph --version 2>/dev/null || echo "$ver"))"
  ensure_gitignore ".code-review-graph/"

  warn "Its configurator writes MCP entries, hooks, skills, and rules for the chosen agents."
  if confirm "Configure code-review-graph for the selected track(s) now?" n; then
    local platform
    for platform in claude:claude-code copilot:copilot; do
      printf '%s\n' "${tracks:-}" | grep -Fqx "${platform%%:*}" || continue
      code-review-graph install --platform "${platform#*:}" >/dev/null 2>&1 \
        && ok "configured code-review-graph for ${platform#*:}" \
        || warn "configuration failed; run 'code-review-graph install --platform ${platform#*:}'"
    done
  else
    info "Binary installed only. Configure later with: code-review-graph install"
  fi
  info "Next: code-review-graph build (then 'update' incrementally). Restart your agent after configuring."
}
