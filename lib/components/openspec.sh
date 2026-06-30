#!/usr/bin/env bash
# components/openspec.sh — install OpenSpec and initialize it in the project.
# OpenSpec is the persistent spec/requirements/tasks layer. Requires Node/npm.
# The correct npm package is @fission-ai/openspec (not the placeholder "openspec").
# Override version with AITO_OPENSPEC_VERSION (default: latest; pin once validated).

install_openspec() {
  step "OpenSpec"
  if ! have npm; then
    warn "npm not found — install Node.js, then re-run. Skipping OpenSpec."
    return 1
  fi
  local pkg="@fission-ai/openspec"
  local ver="${AITO_OPENSPEC_VERSION:-latest}"

  if have openspec; then
    ok "openspec already on PATH ($(openspec --version 2>/dev/null || echo '?'))"
  else
    info "installing $pkg@$ver (global, npm)…"
    npm install -g "$pkg@$ver" >/dev/null 2>&1 \
      && ok "installed $pkg@$ver" \
      || warn "global install failed; will fall back to npx for init"
  fi

  if [ -d openspec ]; then
    ok "openspec/ already initialized"
  else
    info "initializing OpenSpec in $(pwd)…"
    # Use --tools to avoid interactive prompts; default to github-copilot,claude.
    # An array keeps the two args separate without relying on word-splitting.
    local tools_flag=(--tools "github-copilot,claude")
    if have openspec; then
      openspec init "${tools_flag[@]}" >/dev/null 2>&1 || warn "'openspec init' failed (run it manually)"
    else
      npx --yes "$pkg@$ver" init "${tools_flag[@]}" >/dev/null 2>&1 || warn "'npx openspec init' failed (run it manually)"
    fi
  fi

  # Drop our concise config only if OpenSpec did not create one.
  if [ ! -f openspec/config.yaml ]; then
    render_template "$AITO_TEMPLATES/openspec/config.yaml" "openspec/config.yaml"
  fi

  info "Security: pin the version (AITO_OPENSPEC_VERSION) and review generated prompt files."
  info "Workflow: /opsx:propose → review → /opsx:apply → /opsx:verify → /opsx:archive"
  # v1.5.0 adds 'Stores' (early beta) — a new spec/change layout that will replace the
  # workspace/initiative model. It is opt-in; the default 'openspec init' flow above is
  # unaffected. Avoid Stores until it stabilizes (upstream warns of breaking changes).
}
