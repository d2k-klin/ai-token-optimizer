#!/usr/bin/env bash
# components/graphify.sh — OPTIONAL knowledge-graph repo map.
# Alternative to Codesight (choose ONE). Best for heterogeneous repos: code +
# docs + PDFs + diagrams + cross-language relationships.
# See https://github.com/safishamsi/graphify

install_graphify() {
  step "Graphify (optional knowledge graph)"
  if [ -d .codesight ] || ls .codesight* >/dev/null 2>&1; then
    warn "Codesight artifacts detected — the spec recommends choosing ONE mapper, not both."
  fi
  if ! have npx; then warn "npx (Node.js) not found — skipping Graphify."; return 1; fi
  warn "Graphify persists a broad knowledge graph (graphify-out/) — review before committing."
  if confirm "Generate the Graphify graph now?" n; then
    npx --yes graphify >/dev/null 2>&1 \
      && ok "generated graphify-out/" \
      || warn "Graphify generation failed — see the repo for usage"
  else
    info "Skipped generation. Run Graphify when broad relationship questions become common."
  fi
  ensure_gitignore "graphify-out/"
}
