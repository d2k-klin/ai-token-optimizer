#!/usr/bin/env bash
# components/rtk.sh — install RTK (compress noisy terminal output).
# RTK is a Rust binary (rtk-ai/rtk) installed via Homebrew or curl.
# Defaults to EXPLICIT mode (`rtk git diff`, `rtk vitest`, …). The automatic
# Copilot hook (`rtk init -g --copilot`) is offered but OFF by default, per the
# spec's "start in explicit mode" caution.

install_rtk() {
  step "RTK"

  if have rtk && rtk gain >/dev/null 2>&1; then
    ok "rtk already on PATH ($(rtk --version 2>/dev/null || echo '?'))"
  else
    # The npm "rtk" package is NOT the correct one (that's a release toolkit).
    # The real RTK (rtk-ai/rtk) is a Rust binary installed via brew or curl.
    if [ "$AITO_PKG" = "brew" ]; then
      info "installing rtk via Homebrew…"
      brew install rtk >/dev/null 2>&1 \
        && ok "installed rtk ($(rtk --version 2>/dev/null || echo '?'))" \
        || { warn "brew install rtk failed — see https://github.com/rtk-ai/rtk for install steps"; return 1; }
    else
      info "installing rtk via install script…"
      curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh >/dev/null 2>&1 \
        && ok "installed rtk" \
        || { warn "rtk install failed — see https://github.com/rtk-ai/rtk for install steps"; return 1; }
    fi
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
