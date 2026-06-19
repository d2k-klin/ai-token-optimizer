#!/usr/bin/env bash
# components/codesight.sh — OPTIONAL AST-based repo map / wiki.
# Add only if Copilot/Claude repeatedly re-reads many files or misses blast radius.
# Start with the static wiki (not an MCP server). See https://github.com/Houseofmvps/codesight

install_codesight() {
  step "Codesight (optional repo map)"
  if ! have npx; then warn "npx (Node.js) not found — skipping Codesight."; return 1; fi
  warn "Codesight scans and persists concentrated architecture context — review output before committing."
  if confirm "Generate the Codesight static wiki now (npx codesight --wiki)?" n; then
    npx --yes codesight --wiki >/dev/null 2>&1 \
      && ok "generated Codesight wiki" \
      || warn "Codesight wiki generation failed — see the repo for usage"
  else
    info "Skipped generation. Run 'npx codesight --wiki' when exploration is demonstrably weak."
  fi
  ensure_gitignore ".codesight/"
  info "Then instruct the agent to read only the wiki index + the relevant topic page."
}
