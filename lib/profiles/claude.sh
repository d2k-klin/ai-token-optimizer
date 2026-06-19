#!/usr/bin/env bash
# profiles/claude.sh — Claude Code + VS Code track.
# Writes CLAUDE.md (concise + token-discipline guidance), the ACE playbook,
# .claude settings, VS Code integration, and gitignore entries. Idempotent.
# Requires common.sh + playbook.sh sourced.

apply_claude_profile() {
  step "Claude Code track"

  # Project memory: concise-response + lazy-context + token-discipline rules.
  render_template "$AITO_TEMPLATES/claude/CLAUDE.md" "CLAUDE.md"

  # ACE evolving playbook (also referenced by CLAUDE.md).
  playbook_init

  # Minimal .claude project settings: a permissions skeleton users can extend.
  if [ ! -f ".claude/settings.json" ]; then
    write_file ".claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
JSON
  else
    info "unchanged: .claude/settings.json (already present)"
  fi

  # VS Code: shared token-efficiency settings + Claude Code extension.
  vscode_merge_settings
  vscode_install_ext "anthropic.claude-code"

  ensure_gitignore "token-report.md" "*.bak" "repomix-output.*" "graphify-out/" ".codesight/"

  ok "Claude Code track configured"
  info "Open this folder in VS Code with the Claude Code extension, or run 'claude' in the terminal."
}
