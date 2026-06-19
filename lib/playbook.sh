#!/usr/bin/env bash
# playbook.sh — ACE-style evolving playbook (Agentic Context Engineering).
# Maintains a per-project docs/ai-playbook.md of accumulated, deduplicated lessons.
# Inspired by ACE (Generator/Reflector/Curator + evolving playbook, incremental
# deltas to avoid "context collapse"). `aito learn` is the Curator-lite step:
# it appends a delta instead of rewriting the whole file.
# Requires common.sh sourced first.

PLAYBOOK_PATH="docs/ai-playbook.md"

playbook_init() {
  if [ -f "$PLAYBOOK_PATH" ]; then
    info "playbook present: $PLAYBOOK_PATH"
    return 0
  fi
  render_template "$AITO_TEMPLATES/claude/playbook.md" "$PLAYBOOK_PATH"
}

# cmd_learn "<lesson>" — append a deduplicated bullet under the Lessons section.
cmd_learn() {
  local lesson="$*"
  [ -n "$lesson" ] || die 'usage: aito learn "<lesson>"'
  [ -f "$PLAYBOOK_PATH" ] || playbook_init

  # Dedup: skip if an identical bullet body already exists (ignoring date prefix).
  if grep -Fq -- "$lesson" "$PLAYBOOK_PATH"; then
    warn "already recorded; skipping duplicate"
    return 0
  fi

  local date_str; date_str="$(date +%Y-%m-%d)"
  local entry="- ($date_str) $lesson"

  if grep -q '^## Lessons' "$PLAYBOOK_PATH"; then
    # Insert right after the "## Lessons" heading line (portable awk, no in-place).
    local tmp; tmp="$(mktemp)"
    awk -v e="$entry" '
      { print }
      /^## Lessons/ && !done { print ""; print e; done=1 }
    ' "$PLAYBOOK_PATH" >"$tmp"
    mv "$tmp" "$PLAYBOOK_PATH"
  else
    printf '\n## Lessons\n\n%s\n' "$entry" >>"$PLAYBOOK_PATH"
  fi
  ok "recorded lesson in $PLAYBOOK_PATH"
}
