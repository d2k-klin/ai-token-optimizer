#!/usr/bin/env bash
# tests/run.sh — run the full local test suite (shellcheck + bats).
# Skips a linter/runner that isn't installed (with guidance) rather than failing hard,
# so it's useful even on a fresh machine. Exits non-zero if any present check fails.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

SCRIPTS=(bin/aito install.sh lib/*.sh lib/profiles/*.sh lib/components/*.sh)
rc=0

echo "== shellcheck =="
if command -v shellcheck >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  shellcheck -x ${SCRIPTS[*]} && echo "shellcheck: PASS" || { echo "shellcheck: FAIL"; rc=1; }
else
  echo "shellcheck not installed — skipping (brew install shellcheck | apt-get install shellcheck)"
fi

echo
echo "== bats =="
if command -v bats >/dev/null 2>&1; then
  bats tests/ || rc=1
else
  echo "bats not installed — skipping (brew install bats-core | apt-get install bats)"
fi

echo
if [ "$rc" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$rc"
