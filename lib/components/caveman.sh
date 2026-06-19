#!/usr/bin/env bash
# components/caveman.sh — OPTIONAL full Caveman package.
# The spec's recommendation is "Caveman idea, not necessarily the full package":
# the concise-output instruction file (Caveman-lite) is ALWAYS written by the track
# profiles. This installer only adds the upstream Caveman tooling if you explicitly
# want it. See https://github.com/JuliusBrussee/caveman
#
# NOTE: The pip "caveman" package is an unrelated HTML5 manifest validator.
# The real Caveman is installed via its curl|bash script and requires Node ≥18.

install_caveman() {
  step "Caveman (full package — optional)"
  info "Caveman-lite (the concise-output instruction block) is already applied by the track."
  if ! confirm "Also install the full upstream Caveman tooling?" n; then
    info "Skipped full Caveman; keeping the lightweight instruction-only approach."
    return 0
  fi
  if ! have node; then
    warn "Node.js ≥18 required for Caveman — install Node first."
    return 1
  fi
  info "installing Caveman via official installer…"
  curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash >/dev/null 2>&1 \
    && ok "installed Caveman" \
    || warn "Caveman install failed — see https://github.com/JuliusBrussee/caveman"
}
