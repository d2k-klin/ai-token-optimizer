#!/usr/bin/env bash
# tokens.sh — token counting with best-available method.
# Order: tiktoken (python3) when present → chars/4 estimate fallback.
# Requires common.sh sourced first.
#
# Public API:
#   token_method                  — echoes "tiktoken" or "estimate" (cached)
#   token_count_text              — reads stdin, echoes integer token count
#   token_count_file <path>       — echoes integer token count for a file (0 if missing)
#   pct_reduction <before> <after> — echoes integer percent reduction (>=0)

token_method() {
  if [ -n "${AITO_TOKEN_METHOD:-}" ]; then echo "$AITO_TOKEN_METHOD"; return; fi
  if have python3 && python3 -c 'import tiktoken' >/dev/null 2>&1; then
    AITO_TOKEN_METHOD="tiktoken"
  else
    AITO_TOKEN_METHOD="estimate"
  fi
  export AITO_TOKEN_METHOD
  echo "$AITO_TOKEN_METHOD"
}

token_count_text() {
  if [ "$(token_method)" = "tiktoken" ]; then
    python3 - <<'PY'
import sys
import tiktoken
enc = tiktoken.get_encoding("cl100k_base")
data = sys.stdin.read()
print(len(enc.encode(data)))
PY
  else
    # chars/4 heuristic (OpenAI rule of thumb). Clearly an estimate.
    local chars
    chars="$(wc -c | tr -d '[:space:]')"
    [ -z "$chars" ] && chars=0
    echo $(((chars + 3) / 4))
  fi
}

token_count_file() {
  local path="$1"
  [ -f "$path" ] || { echo 0; return; }
  token_count_text <"$path"
}

pct_reduction() {
  local before="$1" after="$2"
  if [ "${before:-0}" -le 0 ]; then echo 0; return; fi
  local diff=$((before - after))
  [ "$diff" -lt 0 ] && diff=0
  echo $(((diff * 100) / before))
}
