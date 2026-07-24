#!/usr/bin/env bash
# components/claude-mem.sh — OPTIONAL compressed memory across agent sessions.
# Installs through the official npx setup path; a global npm install is only the
# SDK and does not register hooks or start the worker.

install_claude_mem() {
  step "Claude-Mem (optional session memory)"
  if ! printf '%s\n' "${tracks:-}" | grep -Fqx claude; then
    warn "Claude-Mem auto-setup currently targets the Claude Code track; skipping."
    return 1
  fi
  if ! have npx; then warn "npx not found — install Node.js, then re-run."; return 1; fi
  if ! node_at_least 20.12; then
    warn "Claude-Mem requires Node.js >=20.12. Upgrade Node, then re-run."
    return 1
  fi

  warn "Claude-Mem persists prompts, tool observations, and summaries and runs a local worker."
  warn "Review what may contain secrets; use <private>...</private> for excluded content."
  if ! confirm "Install Claude-Mem and register its Claude Code hooks?" n; then
    info "Claude-Mem skipped."
    return 0
  fi

  local ver="${AITO_CLAUDE_MEM_VERSION:-latest}"
  if npx --yes "claude-mem@$ver" install; then
    ok "Claude-Mem installed"
  else
    warn "Claude-Mem setup failed — see https://github.com/thedotmack/claude-mem"
    return 1
  fi
}
