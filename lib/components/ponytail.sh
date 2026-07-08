#!/usr/bin/env bash
# components/ponytail.sh — install Ponytail, a minimal-code ruleset plugin.
# Makes the agent write the least code that works, via a prioritization ladder:
# necessity → reuse existing patterns → stdlib → platform features → installed
# deps → only then custom code. Complements Caveman-lite: Caveman trims prose,
# Ponytail trims *generated code* (fewer output tokens, less code to review).
# See https://ponytail.dev and https://github.com/DietrichGebert/ponytail
#
# Plugin-based: installs into the agent host (Claude Code / Copilot CLI), not
# via npm — so there is no AITO_*_VERSION pin; the marketplace serves latest.
# Node.js on PATH is only needed for its optional lifecycle-hook notices.

install_ponytail() {
  step "Ponytail (minimal-code ruleset)"
  local repo="DietrichGebert/ponytail"

  # Claude Code — scripted install via the claude CLI when available.
  if have claude; then
    info "installing Ponytail plugin into Claude Code…"
    if claude plugin marketplace add "$repo" >/dev/null 2>&1 \
       && claude plugin install ponytail@ponytail >/dev/null 2>&1; then
      ok "installed Ponytail plugin (Claude Code)"
    else
      warn "scripted install failed — inside Claude Code run these two prompts:"
      info "  /plugin marketplace add $repo"
      info "  /plugin install ponytail@ponytail"
    fi
  else
    info "Claude Code CLI not found — inside Claude Code run these two prompts:"
    info "  /plugin marketplace add $repo"
    info "  /plugin install ponytail@ponytail"
  fi

  # GitHub Copilot CLI (native VS Code Copilot uses instruction files instead).
  if have copilot; then
    info "installing Ponytail plugin into Copilot CLI…"
    if copilot plugin marketplace add "$repo" >/dev/null 2>&1 \
       && copilot plugin install ponytail@ponytail >/dev/null 2>&1; then
      ok "installed Ponytail plugin (Copilot CLI)"
    else
      warn "scripted install failed — inside Copilot CLI run:"
      info "  copilot plugin marketplace add $repo"
      info "  copilot plugin install ponytail@ponytail   # then /ponytail:ponytail full"
    fi
  fi

  have node || info "Note: Node.js on PATH enables Ponytail's optional lifecycle-hook notices."

  info "Intensity: /ponytail lite|full|ultra|off (default 'full'; override with"
  info "  PONYTAIL_DEFAULT_MODE or ~/.config/ponytail/config.json)"
  info "Commands:  /ponytail-review (diff over-engineering) · /ponytail-audit (repo bloat)"
  info "           /ponytail-debt (deferred shortcuts) · /ponytail-help"
  info "Uninstall: run 'node scripts/uninstall.js' BEFORE removing the plugin from the host."
}
