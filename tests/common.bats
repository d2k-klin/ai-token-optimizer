#!/usr/bin/env bats
load helper

setup()    { setup_aito_env; load_libs; }
teardown() { teardown_aito_env; }

@test "write_file creates a new file" {
  echo "hello" | write_file "out.txt"
  [ -f out.txt ]
  [ "$(cat out.txt)" = "hello" ]
}

@test "write_file backs up a differing existing file once" {
  printf 'old\n' > out.txt
  echo "new" | write_file "out.txt"
  [ "$(cat out.txt)" = "new" ]
  [ -f out.txt.bak ]
  [ "$(cat out.txt.bak)" = "old" ]
}

@test "write_file leaves identical content unchanged (no .bak)" {
  printf 'same\n' > out.txt
  printf 'same\n' | write_file "out.txt"
  [ ! -f out.txt.bak ]
}

@test "ensure_line is idempotent" {
  ensure_line ".gitignore" "node_modules"
  ensure_line ".gitignore" "node_modules"
  run grep -c '^node_modules$' .gitignore
  [ "$output" = "1" ]
}

@test "confirm honors default 'no' under assume-yes (risky opt-ins stay off)" {
  run confirm "enable risky thing?" n
  [ "$status" -ne 0 ]
}

@test "confirm honors default 'yes' under assume-yes" {
  run confirm "do safe thing?" y
  [ "$status" -eq 0 ]
}
