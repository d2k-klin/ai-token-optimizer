#!/usr/bin/env bash
# components/qmd.sh — OPTIONAL local hybrid retrieval over project documentation.
# Combines BM25, vector search, and local reranking; model downloads happen only
# when the user later runs qmd embed/query.

install_qmd() {
  step "QMD (optional local documentation retrieval)"
  if ! have npm; then warn "npm not found — install Node.js, then re-run."; return 1; fi
  if ! node_at_least 22; then
    warn "QMD requires Node.js >=22. Upgrade Node, then re-run."
    return 1
  fi

  local ver="${AITO_QMD_VERSION:-latest}"
  info "installing/updating @tobilu/qmd@$ver (global, npm)…"
  if npm install -g "@tobilu/qmd@$ver" >/dev/null 2>&1 && have qmd; then
    ok "QMD ready ($(qmd --version 2>/dev/null || echo "$ver"))"
  else
    warn "QMD install failed — see https://github.com/tobi/qmd"
    return 1
  fi

  ensure_gitignore ".qmd/*.sqlite*"
  info "Next: qmd init; add docs/openwiki/openspec collections; then run qmd embed."
  warn "'qmd embed' downloads about 2 GB of local GGUF models; it is not run by aito."
}
