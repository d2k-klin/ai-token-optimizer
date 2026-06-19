#!/usr/bin/env bash
# components/caveman.sh — OPTIONAL full Caveman package.
# The spec's recommendation is "Caveman idea, not necessarily the full package":
# the concise-output instruction file (Caveman-lite) is ALWAYS written by the track
# profiles. This installer only adds the upstream Caveman tooling if you explicitly
# want it. See https://github.com/JuliusBrussee/caveman

install_caveman() {
  step "Caveman (full package — optional)"
  info "Caveman-lite (the concise-output instruction block) is already applied by the track."
  if ! confirm "Also install the full upstream Caveman tooling?" n; then
    info "Skipped full Caveman; keeping the lightweight instruction-only approach."
    return 0
  fi
  if have pipx; then
    pipx install caveman >/dev/null 2>&1 && ok "installed caveman via pipx" \
      || warn "pipx install failed — see the Caveman repo for manual steps"
  elif have pip3; then
    warn "prefer pipx; attempting pip3 --user install"
    pip3 install --user caveman >/dev/null 2>&1 && ok "installed caveman via pip3" \
      || warn "pip3 install failed — see the Caveman repo for manual steps"
  else
    warn "no pipx/pip3 found — install from https://github.com/JuliusBrussee/caveman"
  fi
}
