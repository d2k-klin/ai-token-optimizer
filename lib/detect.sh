#!/usr/bin/env bash
# detect.sh — environment detection. Sets globals; no installs here.
# Requires common.sh sourced first (for have/warn).

# detect_os -> sets AITO_OS to darwin|linux and AITO_ARCH
detect_os() {
  case "$(uname -s)" in
    Darwin) AITO_OS="darwin" ;;
    Linux)  AITO_OS="linux"  ;;
    *)      AITO_OS="unknown" ;;
  esac
  AITO_ARCH="$(uname -m)"
  export AITO_OS AITO_ARCH
}

# detect_pkg_mgr -> sets AITO_PKG to brew|apt|dnf|pacman|zypper|none
detect_pkg_mgr() {
  if   have brew;   then AITO_PKG="brew"
  elif have apt-get; then AITO_PKG="apt"
  elif have dnf;    then AITO_PKG="dnf"
  elif have pacman; then AITO_PKG="pacman"
  elif have zypper; then AITO_PKG="zypper"
  else AITO_PKG="none"
  fi
  export AITO_PKG
}

# pkg_install <brew-name> [apt-name] — install an OS package via detected mgr.
# Falls back to the brew name when a per-manager name is not supplied.
pkg_install() {
  local name="$1" alt="${2:-$1}"
  case "$AITO_PKG" in
    brew)   brew install "$name" ;;
    apt)    sudo apt-get update -qq && sudo apt-get install -y "$alt" ;;
    dnf)    sudo dnf install -y "$alt" ;;
    pacman) sudo pacman -S --noconfirm "$alt" ;;
    zypper) sudo zypper install -y "$alt" ;;
    *)      warn "no supported package manager; please install '$name' manually"; return 1 ;;
  esac
}

# detect_tools -> sets AITO_HAS_NODE / NPM / GH / CODE / GIT (1/0)
detect_tools() {
  have node && AITO_HAS_NODE=1 || AITO_HAS_NODE=0
  have npm  && AITO_HAS_NPM=1  || AITO_HAS_NPM=0
  have gh   && AITO_HAS_GH=1   || AITO_HAS_GH=0
  have code && AITO_HAS_CODE=1 || AITO_HAS_CODE=0
  have git  && AITO_HAS_GIT=1  || AITO_HAS_GIT=0
  export AITO_HAS_NODE AITO_HAS_NPM AITO_HAS_GH AITO_HAS_CODE AITO_HAS_GIT
}

# detect_all — run everything; cheap, safe to call repeatedly.
detect_all() {
  detect_os; detect_pkg_mgr; detect_tools
}

# print_env — human-readable environment summary.
print_env() {
  detect_all
  step "Environment"
  info "OS:           $AITO_OS ($AITO_ARCH)"
  info "Package mgr:  $AITO_PKG"
  info "node:         $( [ "$AITO_HAS_NODE" = 1 ] && node -v 2>/dev/null || echo 'not found')"
  info "npm:          $( [ "$AITO_HAS_NPM"  = 1 ] && npm -v 2>/dev/null  || echo 'not found')"
  info "git:          $( [ "$AITO_HAS_GIT"  = 1 ] && echo present || echo 'not found')"
  info "gh CLI:       $( [ "$AITO_HAS_GH"   = 1 ] && echo present || echo 'not found')"
  info "VS Code CLI:  $( [ "$AITO_HAS_CODE" = 1 ] && echo present || echo 'not found')"
}
