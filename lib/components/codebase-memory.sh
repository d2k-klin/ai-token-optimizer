#!/usr/bin/env bash
# components/codebase-memory.sh — OPTIONAL local structural code knowledge graph.
# npm installs the signed/checksummed native binary wrapper. Agent configuration,
# hooks, and its coordination daemon remain behind a separate confirmation.

install_codebase_memory() {
  step "Codebase-Memory-MCP (optional structural retrieval)"
  if ! have npm; then warn "npm not found — install Node.js, then re-run."; return 1; fi
  if ! node_at_least 18; then
    warn "Codebase-Memory-MCP requires Node.js >=18. Upgrade Node, then re-run."
    return 1
  fi

  local ver="${AITO_CODEBASE_MEMORY_VERSION:-latest}"
  info "installing/updating codebase-memory-mcp@$ver (global, npm)…"
  if npm install -g "codebase-memory-mcp@$ver" >/dev/null 2>&1 \
     && have codebase-memory-mcp; then
    ok "Codebase-Memory-MCP ready ($(codebase-memory-mcp --version 2>/dev/null || echo "$ver"))"
  else
    warn "Codebase-Memory-MCP install failed — see https://github.com/DeusData/codebase-memory-mcp"
    return 1
  fi

  ensure_gitignore ".codebase-memory/"
  warn "Its configurator writes detected agent MCP configs, instructions, skills, and hooks."
  if confirm "Run the Codebase-Memory-MCP agent configurator now?" n; then
    codebase-memory-mcp install \
      && ok "Codebase-Memory-MCP configured" \
      || warn "configuration failed; run 'codebase-memory-mcp install' manually"
  else
    info "Binary installed only. Configure later with: codebase-memory-mcp install"
  fi
  info "Remove .codebase-memory/ from .gitignore only if you deliberately share its graph."
}
