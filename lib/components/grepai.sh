#!/usr/bin/env bash
# components/grepai.sh — OPTIONAL local semantic code search and call graphs.
# Prefer Homebrew; otherwise a pinned Go source build avoids the upstream
# shell installer's unchecked binary download.

install_grepai() {
  step "grepai (optional semantic code retrieval)"
  local ver="${AITO_GREPAI_VERSION:-v0.35.0}"
  case "$ver" in v*) ;; *) ver="v$ver" ;; esac

  if [ "${AITO_PKG:-none}" = "brew" ] && have brew; then
    info "installing/updating grepai via Homebrew…"
    brew upgrade yoanbernabeu/tap/grepai >/dev/null 2>&1 \
      || brew install yoanbernabeu/tap/grepai >/dev/null 2>&1 \
      || { warn "grepai Homebrew install failed"; return 1; }
  elif have go; then
    info "installing grepai@$ver from source with Go…"
    go install "github.com/yoanbernabeu/grepai/cmd/grepai@$ver" >/dev/null 2>&1 \
      || { warn "grepai Go install failed (current source requires Go 1.24.2+)"; return 1; }
  elif ! have grepai; then
    warn "Install grepai from its checksummed release assets:"
    warn "https://github.com/yoanbernabeu/grepai/releases/tag/$ver"
    return 1
  fi

  have grepai || { warn "grepai installed but is not on PATH"; return 1; }
  ok "grepai ready ($(grepai --version 2>/dev/null || echo "$ver"))"
  ensure_gitignore ".grepai/index.gob"
  info "Next: configure Ollama/LM Studio (local) or OpenAI, then run 'grepai init'."
  warn "A cloud embedding provider receives indexed code chunks; local providers do not."
}
