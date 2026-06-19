#!/usr/bin/env bash
# components/headroom.sh — OPTIONAL, ADVANCED. Off by default.
# Headroom compresses tool outputs, files, RAG material, and conversation context
# *before they reach the model* by running a LOCAL PROXY in front of your AI client.
# See https://github.com/chopratejas/headroom
#
# IMPORTANT NOTE (read before enabling):
#   • It becomes an intermediary in your model traffic: it intercepts, transforms,
#     caches, and authenticates requests (its Copilot path stores a Headroom-specific
#     GitHub OAuth token).
#   • Its documented integration targets **GitHub Copilot CLI**, NOT native VS Code
#     Copilot — only enable it if you actually use a supported client.
#   • Compression can omit details the model later needs. Never rely on it for
#     security, infrastructure, or error/stack-trace output.
#   • It enlarges your security and debugging boundary. Treat it as a reviewed
#     dependency, pin the version, and keep it on localhost.

install_headroom() {
  step "Headroom (AI-traffic compression proxy — advanced)"
  warn "Headroom runs a LOCAL PROXY that intercepts, transforms, caches, and authenticates"
  warn "your AI traffic. Documented for Copilot CLI (not native VS Code Copilot)."
  warn "Compressed context can drop detail — do not use it for security/infra/error output."

  if ! confirm "I understand the above — install Headroom now?" n; then
    info "Skipped Headroom. The default workflow stays proxy-free."
    return 0
  fi

  if have headroom; then
    ok "headroom already on PATH ($(headroom --version 2>/dev/null || echo '?'))"
  elif have pipx; then
    info "installing headroom-ai via pipx…"
    pipx install headroom-ai >/dev/null 2>&1 \
      && ok "installed headroom via pipx" \
      || warn "pipx install failed — see https://github.com/chopratejas/headroom for setup"
  elif have pip3; then
    warn "prefer pipx; attempting pip3 --user install"
    pip3 install --user headroom-ai >/dev/null 2>&1 \
      && ok "installed headroom via pip3" \
      || warn "pip3 install failed — see https://github.com/chopratejas/headroom for setup"
  else
    warn "no pipx/pip3 found — install from https://github.com/chopratejas/headroom"
  fi

  warn "Security-review it before routing real traffic, pin the version, and bind it to localhost."
}
