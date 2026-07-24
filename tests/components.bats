#!/usr/bin/env bats
load helper

setup()    { setup_aito_env; load_libs; }
teardown() { teardown_aito_env; }

@test "Graphify uses the current package and installs selected host skills" {
  export MOCK_LOG="$PROJECT/tool.log"
  local tool
  for tool in node npm graphify; do
    printf '#!/usr/bin/env bash\nprintf "%%s\\t%%s\\n" "%s" "$*" >>"$MOCK_LOG"\nexit 0\n' \
      "$tool" >"$MOCKBIN/$tool"
    chmod +x "$MOCKBIN/$tool"
  done
  export tracks=$'copilot\nclaude'

  # shellcheck source=lib/components/graphify.sh
  . "$AITO_LIB/components/graphify.sh"
  install_graphify

  grep -Fqx $'npm\tinstall -g @sentropic/graphify@latest' "$MOCK_LOG"
  grep -Fqx $'graphify\tinstall --platform claude' "$MOCK_LOG"
  grep -Fqx $'graphify\tinstall --platform vscode' "$MOCK_LOG"
  grep -Fqx '.graphify/' .gitignore
}

@test "RTK forwards AITO_RTK_VERSION to the verified upstream installer" {
  export MOCK_PIN_LOG="$PROJECT/rtk-version"
  export AITO_RTK_VERSION="v0.43.0"
  export AITO_PKG="none"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'echo '\''printf "%s" "$RTK_VERSION" >"$MOCK_PIN_LOG"'\''' \
    >"$MOCKBIN/curl"
  chmod +x "$MOCKBIN/curl"

  # shellcheck source=lib/components/rtk.sh
  . "$AITO_LIB/components/rtk.sh"
  install_rtk

  [ "$(cat "$MOCK_PIN_LOG")" = "v0.43.0" ]
}

@test "OpenWiki installs by default without adding its GitHub Action" {
  export MOCK_LOG="$PROJECT/openwiki.log"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$*" >>"$MOCK_LOG"' \
    'exit 0' >"$MOCKBIN/npm"
  chmod +x "$MOCKBIN/npm"

  aito setup >/dev/null

  grep -Fqx 'install -g openwiki@latest' "$MOCK_LOG"
  [ ! -e .github/workflows/openwiki-update.yml ]
}

@test "OpenWiki adds its GitHub Action after confirmation and preserves an existing one" {
  confirm() { return 0; }

  # shellcheck source=lib/components/openwiki.sh
  . "$AITO_LIB/components/openwiki.sh"
  install_openwiki

  [ -f .github/workflows/openwiki-update.yml ]
  grep -Fq 'openwiki code --update --print' .github/workflows/openwiki-update.yml
  grep -Fq 'OPENWIKI_TELEMETRY_DISABLED: "1"' .github/workflows/openwiki-update.yml

  printf '%s\n' 'name: Custom OpenWiki workflow' >.github/workflows/openwiki-update.yml
  install_openwiki
  grep -Fqx 'name: Custom OpenWiki workflow' .github/workflows/openwiki-update.yml
  [ ! -e .github/workflows/openwiki-update.yml.bak ]
}
