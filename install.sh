#!/usr/bin/env bash
# install.sh — bootstrap the `aito` CLI onto your PATH.
# Idempotent. macOS/Linux, Bash 3.2+. No sudo unless a system prefix is chosen.
#
#   bash install.sh                 # install for current user (~/.local)
#   PREFIX=/usr/local bash install.sh   # system-wide (may require sudo)
#   bash install.sh --uninstall

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SRC_DIR/lib/common.sh"
# shellcheck source=lib/detect.sh
. "$SRC_DIR/lib/detect.sh"

PREFIX="${PREFIX:-$HOME/.local}"
SHARE_DIR="$PREFIX/share/ai-token-optimizer"
BIN_DIR="$PREFIX/bin"
LAUNCHER="$BIN_DIR/aito"

uninstall() {
  step "Uninstalling aito"
  rm -f "$LAUNCHER" && ok "removed $LAUNCHER" || true
  rm -rf "$SHARE_DIR" && ok "removed $SHARE_DIR" || true
  ok "Done. (Your per-project config files were left untouched.)"
}

main() {
  if [ "${1:-}" = "--uninstall" ]; then uninstall; return; fi

  detect_all
  step "Installing ai-token-optimizer"
  info "OS: $AITO_OS / pkg: $AITO_PKG / prefix: $PREFIX"

  # Hard prerequisites
  require_cmd bash
  [ "$AITO_HAS_GIT" = 1 ] || warn "git not found — recommended but not required"

  case "$AITO_OS" in
    darwin|linux) ;;
    *) die "unsupported OS: $(uname -s) (macOS/Linux only)" ;;
  esac

  # Copy the toolkit to a stable location (exclude VCS + tests + dev cruft).
  step "Copying toolkit to $SHARE_DIR"
  mkdir -p "$SHARE_DIR" "$BIN_DIR"
  if have rsync; then
    rsync -a --delete \
      --exclude '.git' --exclude 'node_modules' --exclude 'tests' \
      --exclude '*.bak' "$SRC_DIR"/ "$SHARE_DIR"/
  else
    # Portable fallback: clear then copy.
    rm -rf "$SHARE_DIR"; mkdir -p "$SHARE_DIR"
    ( cd "$SRC_DIR" && tar --exclude='.git' --exclude='node_modules' --exclude='tests' -cf - . ) \
      | ( cd "$SHARE_DIR" && tar -xf - )
  fi
  chmod +x "$SHARE_DIR/bin/aito"
  ok "copied"

  # Launcher: a tiny shim that pins AITO_HOME and execs the real CLI.
  step "Writing launcher $LAUNCHER"
  cat >"$LAUNCHER" <<EOF
#!/usr/bin/env bash
export AITO_HOME="$SHARE_DIR"
exec "$SHARE_DIR/bin/aito" "\$@"
EOF
  chmod +x "$LAUNCHER"
  ok "installed"

  # PATH guidance
  case ":$PATH:" in
    *":$BIN_DIR:"*) ok "$BIN_DIR is already on your PATH" ;;
    *)
      warn "$BIN_DIR is not on your PATH"
      info "Add this to your shell profile (~/.zshrc or ~/.bashrc):"
      # shellcheck disable=SC2016  # literal $PATH is intentional (user copies this line)
      printf '\n    export PATH="%s:$PATH"\n\n' "$BIN_DIR"
      ;;
  esac

  step "Installed"
  ok "Run:  aito setup   (inside a project)   or   aito help"
}

main "$@"
