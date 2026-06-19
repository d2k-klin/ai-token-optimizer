#!/usr/bin/env bash
# profiles/copilot.sh — GitHub Copilot + VS Code track.
# Writes concise instruction files (Caveman-lite), OpenSpec path rule, VS Code
# settings, and gitignore entries. Idempotent. Requires common.sh sourced.

apply_copilot_profile() {
  step "Copilot track"

  # Concise-output + workflow instructions (re-sent often → kept short).
  render_template "$AITO_TEMPLATES/copilot/copilot-instructions.md" \
                  ".github/copilot-instructions.md"

  # Path-scoped rule that keeps OpenSpec artifacts precise (not telegraphic).
  render_template "$AITO_TEMPLATES/copilot/openspec.instructions.md" \
                  ".github/instructions/openspec.instructions.md"

  # VS Code: enable instruction/prompt files, exclude noise from indexing.
  vscode_merge_settings
  vscode_install_ext "github.copilot"
  vscode_install_ext "github.copilot-chat"

  # Keep AI-generated map/export outputs out of VCS by default.
  ensure_gitignore "token-report.md" "*.bak" "repomix-output.*" "graphify-out/" ".codesight/"

  ok "Copilot track configured"
  info "OpenSpec slash commands (e.g. /opsx:propose) appear once OpenSpec is initialized."
}
