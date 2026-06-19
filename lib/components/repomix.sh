#!/usr/bin/env bash
# components/repomix.sh — OPTIONAL one-off repo export + token counting.
# Not permanent per-feature context. Useful for external review, a one-time
# architecture snapshot, or measuring approximate token size.
# See https://github.com/yamadashy/repomix

install_repomix() {
  step "Repomix (optional one-off export)"
  if ! have npx; then warn "npx (Node.js) not found — skipping Repomix."; return 1; fi
  ok "Repomix is available on demand via: npx repomix"
  warn "Always inspect output for secrets before sharing. Do not attach full packs to every prompt."
  ensure_gitignore "repomix-output.*"
  if confirm "Create a token-size snapshot now (npx repomix)?" n; then
    npx --yes repomix >/dev/null 2>&1 \
      && ok "wrote repomix-output.* (inspect before sharing)" \
      || warn "Repomix run failed — see the repo for usage"
  fi
}
