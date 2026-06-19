#!/usr/bin/env bash
# Shared bats helpers. Sets AITO_HOME to the repo under test and provides a
# sandbox project dir + a mock-bin PATH so no real installs happen.

setup_aito_env() {
  AITO_HOME="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export AITO_HOME
  export AITO_LIB="$AITO_HOME/lib"
  export AITO_TEMPLATES="$AITO_HOME/templates"
  export NO_COLOR=1 AITO_ASSUME_YES=1

  # Sandbox project (a git repo) the commands operate on.
  PROJECT="$(mktemp -d)"
  cd "$PROJECT" || return 1
  git init -q
  git config user.email t@t; git config user.name t

  # Mock external tools so installers are network-free no-ops.
  MOCKBIN="$PROJECT/.mockbin"; mkdir -p "$MOCKBIN"
  local t
  for t in npm npx openspec rtk ccusage code gh; do
    printf '#!/usr/bin/env bash\nexit 0\n' >"$MOCKBIN/$t"
    chmod +x "$MOCKBIN/$t"
  done
  export PATH="$MOCKBIN:$PATH"
}

teardown_aito_env() {
  cd /
  [ -n "${PROJECT:-}" ] && rm -rf "$PROJECT"
}

# Source the libraries (for unit tests of individual functions).
load_libs() {
  . "$AITO_LIB/common.sh"
  . "$AITO_LIB/detect.sh"
  . "$AITO_LIB/tokens.sh"
  . "$AITO_LIB/playbook.sh"
  . "$AITO_LIB/verify.sh"
}

aito() { bash "$AITO_HOME/bin/aito" "$@"; }
