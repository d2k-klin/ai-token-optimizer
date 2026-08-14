#!/usr/bin/env bash
# components/serena.sh — OPTIONAL symbol-level code retrieval/editing via LSP.
# Serena is distributed as serena-agent on PyPI and managed with uv.

install_serena() {
  step "Serena (optional symbol retrieval)"
  if ! have uv; then
    warn "uv not found — install it from https://docs.astral.sh/uv/, then re-run."
    return 1
  fi

  local ver="${AITO_SERENA_VERSION:-latest}"
  local spec="serena-agent"
  [ "$ver" = "latest" ] || spec="serena-agent==$ver"
  info "installing/updating $spec with uv (Python 3.13)…"
  if uv tool install --force -p 3.13 "$spec" >/dev/null 2>&1 && have serena; then
    ok "Serena ready ($(SERENA_USAGE_REPORTING=false serena --version 2>/dev/null || echo "$ver"))"
  else
    warn "Serena install failed — see https://github.com/oraios/serena"
    return 1
  fi

  if confirm "Initialize Serena now?" y; then
    SERENA_USAGE_REPORTING=false serena init \
      && ok "initialized Serena" \
      || warn "Serena initialization failed; run 'serena init' manually"
  fi
  if printf '%s\n' "${tracks:-}" | grep -Fqx claude; then
    info "Claude Code: follow Serena's current client setup guide:"
    info "  https://oraios.github.io/serena/02-usage/030_clients.html"
  fi
  if printf '%s\n' "${tracks:-}" | grep -Fqx copilot; then
    info "VS Code Copilot: run 'MCP: Add Server' and enter:"
    info "  serena start-mcp-server --context=vscode --project \${workspaceFolder}"
  fi
  info "Privacy: export SERENA_USAGE_REPORTING=false to disable anonymous startup metrics."
}
