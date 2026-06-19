#!/usr/bin/env bash
# components/gh-aw.sh — OPTIONAL GitHub Agentic Workflows (later automation layer).
# Compiles natural-language workflow definitions into GitHub Actions. Begin
# read-only with narrow triggers. NOT part of the initial feature-delivery stack.
# See https://github.com/github/gh-aw

install_gh_aw() {
  step "gh-aw (optional GitHub automation)"
  if ! have gh; then
    warn "GitHub CLI ('gh') not found — install it first: https://cli.github.com"
    return 1
  fi
  warn "gh-aw runs autonomous agents on GitHub events. Start read-only; test in a non-critical repo."
  if ! confirm "Install the gh-aw extension now?" n; then
    info "Skipped. Add gh-aw only for a clear, low-risk, recurring repository task."
    return 0
  fi
  if gh extension list 2>/dev/null | grep -q 'github/gh-aw'; then
    ok "gh-aw extension already installed"
  else
    gh extension install github/gh-aw >/dev/null 2>&1 \
      && ok "installed gh-aw extension" \
      || warn "extension install failed — see the gh-aw repo"
  fi
  info "Use safe outputs, approval gates, and read-only defaults before any write path."
}
