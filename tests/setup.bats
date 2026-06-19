#!/usr/bin/env bats
load helper

setup()    { setup_aito_env; }
teardown() { teardown_aito_env; }

@test "aito version prints version" {
  run aito version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^aito\ [0-9] ]]
}

@test "aito help lists commands" {
  run aito help
  [ "$status" -eq 0 ]
  [[ "$output" == *"setup"* ]]
  [[ "$output" == *"verify"* ]]
}

@test "non-interactive setup writes both tracks' files" {
  run aito setup
  [ "$status" -eq 0 ]
  [ -f .github/copilot-instructions.md ]
  [ -f .github/instructions/openspec.instructions.md ]
  [ -f CLAUDE.md ]
  [ -f docs/ai-playbook.md ]
  [ -f .claude/settings.json ]
  [ -f .vscode/settings.json ]
  [ -f token-report.md ]
}

@test "setup is idempotent (re-run, no dup gitignore lines)" {
  aito setup >/dev/null
  aito setup >/dev/null
  run grep -c '^token-report.md$' .gitignore
  [ "$output" = "1" ]
}

@test "vscode settings merge keeps existing keys (jq)" {
  if ! command -v jq >/dev/null; then skip "jq not available"; fi
  mkdir -p .vscode
  printf '{ "editor.tabSize": 2 }\n' > .vscode/settings.json
  aito setup >/dev/null
  run jq -r '."editor.tabSize"' .vscode/settings.json
  [ "$output" = "2" ]
  run jq -r '."chat.promptFiles"' .vscode/settings.json
  [ "$output" = "true" ]
}

@test "verify produces a report with a verdict" {
  aito setup >/dev/null
  run aito verify
  [ -f token-report.md ]
  grep -q "## Verdict" token-report.md
}

@test "learn appends a dated, deduplicated lesson" {
  aito setup >/dev/null
  aito learn "use rtk for diffs"
  aito learn "use rtk for diffs"
  run grep -c "use rtk for diffs" docs/ai-playbook.md
  [ "$output" = "1" ]
}

@test "doctor passes on a configured project" {
  aito setup >/dev/null
  run aito doctor
  [ "$status" -eq 0 ]
}

@test "doctor flags a missing config" {
  run aito doctor
  [ "$status" -ne 0 ]
}
