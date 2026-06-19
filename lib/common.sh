#!/usr/bin/env bash
# common.sh — shared helpers: logging, prompts, idempotent file writes.
# Sourced by bin/aito and every lib/* module. No side effects on source.
# Bash 3.2+ compatible (works with stock macOS bash).

# ---------------------------------------------------------------------------
# Colors (disabled when not a TTY or NO_COLOR is set)
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_CYAN=$'\033[36m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_CYAN=''
fi

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
log()   { printf '%s\n' "$*"; }
info()  { printf '%s%s%s\n' "$C_BLUE"  "  $*" "$C_RESET"; }
ok()    { printf '%s%s%s\n' "$C_GREEN" "✓ $*" "$C_RESET"; }
warn()  { printf '%s%s%s\n' "$C_YELLOW" "! $*" "$C_RESET" >&2; }
err()   { printf '%s%s%s\n' "$C_RED"   "✗ $*" "$C_RESET" >&2; }
step()  { printf '\n%s%s%s\n' "$C_BOLD$C_CYAN" "▸ $*" "$C_RESET"; }
die()   { err "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------
# confirm "Question?" [default:y|n] -> returns 0 (yes) / 1 (no)
confirm() {
  local prompt="$1" default="${2:-n}" reply hint
  case "$default" in y|Y) hint="[Y/n]";; *) hint="[y/N]";; esac
  # Non-interactive (assume-yes or no TTY) means "accept the recommended default",
  # NOT "yes to everything" — so risky opt-ins that default to no stay off.
  if [ "${AITO_ASSUME_YES:-0}" = "1" ] || [ ! -t 0 ]; then
    case "$default" in y|Y) return 0;; *) return 1;; esac
  fi
  printf '%s %s ' "$prompt" "$hint" >&2
  read -r reply || reply=""
  reply="${reply:-$default}"
  case "$reply" in y|Y|yes|YES) return 0;; *) return 1;; esac
}

# ---------------------------------------------------------------------------
# Command / tool checks
# ---------------------------------------------------------------------------
have()        { command -v "$1" >/dev/null 2>&1; }
require_cmd()  { have "$1" || die "Required command not found: $1"; }

# ---------------------------------------------------------------------------
# Idempotent file operations
# ---------------------------------------------------------------------------
# write_file <path> <<'EOF' ... EOF
# Writes stdin to path only if content differs. Backs up an existing, differing
# file to <path>.bak (once) and prints a notice. Never silently clobbers.
write_file() {
  local path="$1" tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  if [ -f "$path" ]; then
    if cmp -s "$tmp" "$path"; then
      info "unchanged: $path"
      rm -f "$tmp"; return 0
    fi
    if [ ! -f "$path.bak" ]; then
      cp "$path" "$path.bak"
      warn "existing file differs; backed up to $(basename "$path").bak"
    else
      warn "existing file differs; $(basename "$path").bak already present (not overwritten)"
    fi
  fi
  mkdir -p "$(dirname "$path")"
  mv "$tmp" "$path"
  ok "wrote: $path"
}

# ensure_line <file> <line> — append line if not already present (creates file).
ensure_line() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || : >"$file"
  if grep -Fqx "$line" "$file"; then
    return 0
  fi
  printf '%s\n' "$line" >>"$file"
  ok "added to $(basename "$file"): $line"
}

# ensure_gitignore <pattern> [pattern...] — add patterns to ./.gitignore
ensure_gitignore() {
  local p
  for p in "$@"; do ensure_line ".gitignore" "$p"; done
}

# render_template <template_path> <dest_path>
# Copies a template into place using write_file (so it is idempotent + safe).
render_template() {
  local src="$1" dest="$2"
  [ -f "$src" ] || die "template not found: $src"
  write_file "$dest" <"$src"
}

# ---------------------------------------------------------------------------
# VS Code helpers (shared by both track profiles)
# ---------------------------------------------------------------------------
# vscode_merge_settings — deep-merge templates/vscode/settings.json into
# ./.vscode/settings.json (template keys win). Never clobbers: backs up first.
vscode_merge_settings() {
  local tmpl="$AITO_TEMPLATES/vscode/settings.json" dest=".vscode/settings.json"
  [ -f "$tmpl" ] || { warn "vscode settings template missing"; return 1; }
  mkdir -p .vscode
  if [ ! -f "$dest" ]; then render_template "$tmpl" "$dest"; return; fi
  if have jq; then
    local tmp; tmp="$(mktemp)"
    if jq -s '.[0] * .[1]' "$dest" "$tmpl" >"$tmp" 2>/dev/null; then
      if cmp -s "$tmp" "$dest"; then info "VS Code settings already current"; rm -f "$tmp";
      else cp "$dest" "$dest.bak"; mv "$tmp" "$dest"; ok "merged VS Code settings (backup: settings.json.bak)"; fi
    else warn "could not parse $dest as JSON; left unchanged"; rm -f "$tmp"; fi
  else
    warn "jq not found — not merging $dest automatically. Recommended keys:"
    cat "$tmpl" >&2
  fi
}

# vscode_install_ext <extension-id> — install a VS Code extension if the CLI exists.
vscode_install_ext() {
  local ext="$1"
  if ! have code; then info "VS Code 'code' CLI not found — skipping extension: $ext"; return 0; fi
  if code --list-extensions 2>/dev/null | grep -Fqx "$ext"; then
    ok "VS Code extension present: $ext"
  elif code --install-extension "$ext" >/dev/null 2>&1; then
    ok "installed VS Code extension: $ext"
  else
    warn "could not install VS Code extension: $ext (install it manually)"
  fi
}
