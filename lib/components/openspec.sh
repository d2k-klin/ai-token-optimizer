#!/usr/bin/env bash
# components/openspec.sh — install OpenSpec and initialize it in the project.
# OpenSpec is the persistent spec/requirements/tasks layer. Requires Node >=20.19/npm.
# The correct npm package is @fission-ai/openspec (not the placeholder "openspec").
# Override version with AITO_OPENSPEC_VERSION (default: latest; pin once validated).

install_openspec() {
  step "OpenSpec"
  if ! have npm; then
    warn "npm not found — install Node.js, then re-run. Skipping OpenSpec."
    return 1
  fi
  if ! node_at_least 20.19.0; then
    warn "OpenSpec requires Node.js >=20.19.0. Upgrade Node, then re-run."
    return 1
  fi
  local pkg="@fission-ai/openspec"
  local ver="${AITO_OPENSPEC_VERSION:-latest}"

  info "installing/updating $pkg@$ver (global, npm)…"
  npm install -g "$pkg@$ver" >/dev/null 2>&1 \
    && ok "OpenSpec ready ($(openspec --version 2>/dev/null || echo "$ver"))" \
    || warn "global install failed; will use an existing binary or npx for init"

  if [ -d openspec ]; then
    ok "openspec/ already initialized"
  else
    info "initializing OpenSpec in $(pwd)…"
    # Use --tools to avoid interactive prompts; default to github-copilot,claude.
    # An array keeps the two args separate without relying on word-splitting.
    local tools_flag=(--tools "github-copilot,claude")
    if have openspec; then
      OPENSPEC_TELEMETRY=0 openspec init "${tools_flag[@]}" >/dev/null 2>&1 \
        || warn "'openspec init' failed (run it manually)"
    else
      OPENSPEC_TELEMETRY=0 npx --yes "$pkg@$ver" init "${tools_flag[@]}" >/dev/null 2>&1 \
        || warn "'npx openspec init' failed (run it manually)"
    fi
  fi

  # Drop our concise config only if OpenSpec did not create one.
  if [ ! -f openspec/config.yaml ]; then
    render_template "$AITO_TEMPLATES/openspec/config.yaml" "openspec/config.yaml"
  fi

  info "Security: pin the version (AITO_OPENSPEC_VERSION) and review generated prompt files."
  info "Privacy: aito disables OpenSpec telemetry during init; export OPENSPEC_TELEMETRY=0"
  info "         (or DO_NOT_TRACK=1) to disable it for later OpenSpec commands."
  info "Workflow: /opsx:propose → review → /opsx:apply → /opsx:verify → /opsx:archive"
  # Stores, introduced in v1.5, remain beta in v1.6. They are opt-in; the default
  # 'openspec init' flow above is unaffected.
}
