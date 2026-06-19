#!/usr/bin/env bats
load helper

setup()    { setup_aito_env; load_libs; }
teardown() { teardown_aito_env; }

@test "token_count_text returns a positive integer" {
  run bash -c '. "$AITO_LIB/common.sh"; . "$AITO_LIB/tokens.sh"; printf "hello world foo bar" | token_count_text'
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+$ ]]
  [ "$output" -gt 0 ]
}

@test "token_count_file returns 0 for a missing file" {
  run token_count_file "/nope/does-not-exist"
  [ "$output" = "0" ]
}

@test "pct_reduction computes percent" {
  run pct_reduction 100 25
  [ "$output" = "75" ]
}

@test "pct_reduction clamps negatives to 0" {
  run pct_reduction 100 200
  [ "$output" = "0" ]
}

@test "pct_reduction handles zero baseline" {
  run pct_reduction 0 0
  [ "$output" = "0" ]
}
