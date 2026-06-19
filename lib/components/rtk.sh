#!/usr/bin/env bash
# components/rtk.sh — install RTK (compress noisy terminal output).
# Defaults to EXPLICIT mode (`rtk git diff`, `rtk vitest`, …). The automatic
# Copilot hook (`rtk init -g --copilot`) is offered but OFF by default, per the
# spec's "start in explicit mode" caution. Override version with AITO_RTK_VERSION.

install_rtk() {
  step "RTK"
  if ! have npm; then
    warn "npm not found — install Node.js, then re-run. Skipping RTK."
    return 1
  fi
  local ver="${AITO_RTK_VERSION:-latest}"

  if have rtk; then
    ok "rtk already on PATH ($(rtk --version 2>/dev/null || echo '?'))"
  else
    info "installing rtk@$ver (global, npm)…"
    npm install -g "rtk@$ver" >/dev/null 2>&1 \
      && ok "installed rtk@$ver" \
      || { warn "global install failed — see https://github.com/rtk-ai/rtk for install steps"; return 1; }
  fi

  info "Use explicit RTK for noisy commands: rtk git diff | rtk vitest | rtk tsc | rtk next build"
  warn "Use RAW output for security/infra failures or when exact ordering/warnings matter."

  # Automatic Copilot hook is opt-in (transparently rewrites shell commands).
  if confirm "Enable RTK's automatic Copilot hook now? (not recommended until piloted)" n; then
    rtk init -g --copilot >/dev/null 2>&1 \
      && ok "RTK Copilot hook enabled" \
      || warn "'rtk init -g --copilot' failed (enable it manually after a pilot)"
  else
    info "Skipped auto hook — pilot explicit mode first, then enable if it reduces context."
  fi
}
