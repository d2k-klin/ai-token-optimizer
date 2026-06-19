#!/usr/bin/env bash
# verify.sh — measure that token reduction is actually in place.
# Produces token-report.md and a console summary with PASS/WARN gates.
# Requires common.sh + tokens.sh sourced first.

REPORT_PATH="token-report.md"
INSTRUCTION_TOKEN_BUDGET="${AITO_INSTRUCTION_BUDGET:-1500}"

# Persistent-context files we expect (per track). Missing ones are simply skipped.
_context_files() {
  printf '%s\n' \
    ".github/copilot-instructions.md" \
    "CLAUDE.md" \
    "docs/ai-playbook.md" \
    "openspec/config.yaml"
}

# ---- Measurement 1: instruction conciseness gate --------------------------
_measure_conciseness() {
  local warns=0 f tok
  {
    echo "## 1. Instruction conciseness gate"
    echo
    echo "Instruction files are re-sent on (nearly) every interaction, so they must stay small."
    echo "Budget: ${INSTRUCTION_TOKEN_BUDGET} tokens each (method: $(token_method))."
    echo
    echo "| File | Tokens | Budget | Result |"
    echo "|---|---:|---:|---|"
  } >>"$REPORT_PATH"
  for f in ".github/copilot-instructions.md" "CLAUDE.md"; do
    [ -f "$f" ] || continue
    tok="$(token_count_file "$f")"
    if [ "$tok" -le "$INSTRUCTION_TOKEN_BUDGET" ]; then
      echo "| $f | $tok | $INSTRUCTION_TOKEN_BUDGET | PASS |" >>"$REPORT_PATH"
    else
      echo "| $f | $tok | $INSTRUCTION_TOKEN_BUDGET | WARN (too large) |" >>"$REPORT_PATH"
      warns=$((warns + 1))
    fi
  done
  echo >>"$REPORT_PATH"
  return "$warns"
}

# ---- Measurement 2: RTK terminal-output compression -----------------------
_rtk_pair() {
  # $1 label, $2 raw command (rtk form is "rtk <raw>")
  local label="$1" raw_cmd="$2" raw_out rtk_out raw_tok rtk_tok pct
  raw_out="$(eval "$raw_cmd" 2>/dev/null || true)"
  [ -n "$raw_out" ] || return 1
  rtk_out="$(eval "rtk $raw_cmd" 2>/dev/null || true)"
  [ -n "$rtk_out" ] || return 1   # rtk did not handle it; don't fake a 100% saving
  raw_tok="$(printf '%s' "$raw_out" | token_count_text)"
  rtk_tok="$(printf '%s' "$rtk_out" | token_count_text)"
  pct="$(pct_reduction "$raw_tok" "$rtk_tok")"
  echo "| \`$label\` | $raw_tok | $rtk_tok | ${pct}% |" >>"$REPORT_PATH"
  RTK_SAVED=$((RTK_SAVED + (raw_tok - rtk_tok)))
  RTK_MEASURED=1
}

_measure_rtk() {
  {
    echo "## 2. RTK terminal-output compression"
    echo
  } >>"$REPORT_PATH"
  if ! have rtk; then
    echo "_RTK not installed — skipped. Install it via \`aito setup\` to compress noisy output._" >>"$REPORT_PATH"
    echo >>"$REPORT_PATH"
    return 0
  fi
  RTK_SAVED=0; RTK_MEASURED=0
  {
    echo "Raw vs RTK token counts on read-only commands in this repo:"
    echo
    echo "| Command | Raw | RTK | Reduction |"
    echo "|---|---:|---:|---:|"
  } >>"$REPORT_PATH"
  _rtk_pair "git diff"   "git diff" || true
  _rtk_pair "git status" "git status" || true
  _rtk_pair "git log"    "git log --stat -n 25" || true
  echo >>"$REPORT_PATH"
  if [ "${RTK_MEASURED:-0}" = 0 ]; then
    echo "_No noisy command output available right now (clean tree). Re-run after a build/test/diff._" >>"$REPORT_PATH"
    echo >>"$REPORT_PATH"
  else
    echo "**RTK saved ~${RTK_SAVED} tokens** across the sampled commands." >>"$REPORT_PATH"
    echo >>"$REPORT_PATH"
  fi
  return 0
}

# ---- Measurement 3: targeted context vs whole repo ------------------------
_whole_repo_tokens() {
  # Sum tokens of git-tracked text files, excluding obvious noise, capped at ~5MB.
  have git || { echo 0; return; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo 0; return; }
  local cap=$((5 * 1024 * 1024)) total_bytes=0 f
  local tmp; tmp="$(mktemp)"
  while IFS= read -r f; do
    case "$f" in
      *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.pdf|*.lock|*.min.js|*.map) continue ;;
      *package-lock.json|*pnpm-lock.yaml) continue ;;
    esac
    [ -f "$f" ] || continue
    local sz; sz="$(wc -c <"$f" | tr -d '[:space:]')"
    total_bytes=$((total_bytes + sz))
    cat "$f" >>"$tmp"
    [ "$total_bytes" -ge "$cap" ] && break
  done <<EOF
$(git ls-files 2>/dev/null)
EOF
  token_count_file "$tmp"
  rm -f "$tmp"
}

_measure_targeted() {
  {
    echo "## 3. Targeted context vs whole repository"
    echo
    echo "Lazy/targeted context means loading only the persistent artifacts + the few files a"
    echo "task touches, instead of the whole repo."
    echo
  } >>"$REPORT_PATH"
  local whole targeted pct f tmp
  whole="$(_whole_repo_tokens)"
  tmp="$(mktemp)"
  while IFS= read -r f; do [ -f "$f" ] && cat "$f" >>"$tmp"; done <<EOF
$(_context_files)
EOF
  targeted="$(token_count_file "$tmp")"; rm -f "$tmp"
  {
    echo "| Scope | Tokens |"
    echo "|---|---:|"
    echo "| Whole repo (tracked text, capped 5MB) | $whole |"
    echo "| Persistent context artifacts only | $targeted |"
    echo
    if [ "$whole" -eq 0 ]; then
      echo "_No tracked files yet — commit your code, then re-run to see the lazy-context"
      echo "savings of loading artifacts instead of the whole repo._"
    elif [ "$whole" -le "$targeted" ]; then
      echo "_This repo is small relative to the persistent artifacts, so there is no net"
      echo "saving yet. On a larger codebase, loading only targeted context saves more as"
      echo "repo size grows._"
    else
      pct="$(pct_reduction "$whole" "$targeted")"
      echo "**Targeted context is ~${pct}% smaller** than loading the whole repo."
    fi
    echo
  } >>"$REPORT_PATH"
}

# ---- Measurement 4: persistent-artifact footprint -------------------------
_measure_footprint() {
  {
    echo "## 4. Persistent-artifact footprint"
    echo
    echo "Tokens held in durable files (vs re-explaining the same context in chat each session)."
    echo
    echo "| File | Tokens |"
    echo "|---|---:|"
  } >>"$REPORT_PATH"
  local f tok total=0 present=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    tok="$(token_count_file "$f")"
    total=$((total + tok)); present=$((present + 1))
    echo "| $f | $tok |" >>"$REPORT_PATH"
  done <<EOF
$(_context_files)
EOF
  {
    echo "| **Total** | **$total** |"
    echo
    echo "These $present file(s) replace ad-hoc chat re-explanation. Over N focused sessions"
    echo "they avoid roughly N× that re-explanation cost while keeping decisions reviewable in git."
    echo
  } >>"$REPORT_PATH"
}

# ---- Measurement 5: real usage trend via ccusage (informational) ----------
_measure_usage() {
  {
    echo "## 5. Token-usage trend (ccusage)"
    echo
  } >>"$REPORT_PATH"
  if have ccusage; then
    {
      echo "ccusage is installed — track your real, local token + cost totals over time as"
      echo "the other measures take effect. The gates above are point-in-time; this is the trend."
      echo
      echo '```'
      echo "ccusage            # daily token + cost report"
      echo "ccusage monthly    # monthly totals"
      echo '```'
      echo
    } >>"$REPORT_PATH"
  else
    {
      echo "_ccusage not installed — add it via \`aito setup\` to watch daily/monthly token and"
      echo "cost totals (read from local agent logs) drop as these measures take effect._"
      echo
    } >>"$REPORT_PATH"
  fi
}

cmd_verify() {
  : >"$REPORT_PATH"
  {
    echo "# Token-Reduction Report"
    echo
    echo "_Generated by \`aito verify\` on $(date '+%Y-%m-%d %H:%M') — token method: $(token_method)._"
    echo
  } >>"$REPORT_PATH"

  local warns=0
  _measure_conciseness || warns=$((warns + $?))
  _measure_rtk
  _measure_targeted
  _measure_footprint
  _measure_usage

  {
    echo "## Verdict"
    echo
    if [ "$warns" -eq 0 ]; then
      echo "**PASS** — token-reduction measures are in place. Judge success by delivery"
      echo "outcomes (fewer retries, less irrelevant context), not a single headline percentage."
    else
      echo "**WARN ($warns issue(s))** — see the gates above. Most likely an instruction file"
      echo "exceeds its token budget; trim it (it is re-sent on every interaction)."
    fi
  } >>"$REPORT_PATH"

  step "Token-reduction summary"
  if [ "$warns" -eq 0 ]; then ok "PASS — report written to $REPORT_PATH";
  else warn "$warns warning(s) — report written to $REPORT_PATH"; fi
  info "token method: $(token_method)"
  [ "$warns" -eq 0 ]
}

# ---- doctor ----------------------------------------------------------------
cmd_doctor() {
  detect_all
  step "aito doctor"
  local issues=0 f tok

  # Tools
  for t in node npm git gh code rtk ccusage repomix openspec headroom; do
    if have "$t"; then ok "tool present: $t"; else info "tool absent: $t"; fi
  done

  # Instruction files + budgets
  local found=0
  for f in ".github/copilot-instructions.md" "CLAUDE.md"; do
    if [ -f "$f" ]; then
      found=1
      tok="$(token_count_file "$f")"
      if [ "$tok" -le "$INSTRUCTION_TOKEN_BUDGET" ]; then
        ok "$f present ($tok tokens, within budget)"
      else
        warn "$f is large ($tok > $INSTRUCTION_TOKEN_BUDGET tokens) — trim it"
        issues=$((issues + 1))
      fi
    fi
  done
  [ "$found" = 1 ] || { warn "no instruction files found — run 'aito setup'"; issues=$((issues + 1)); }

  # Secret leakage check (tracked secrets are dangerous in AI context)
  if have git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git ls-files 2>/dev/null | grep -Eq '(^|/)\.env($|\.)' ; then
      warn "a .env file appears to be tracked in git — keep secrets out of AI context"
      issues=$((issues + 1))
    fi
  fi

  if [ "$issues" -eq 0 ]; then ok "doctor: no issues"; else warn "doctor: $issues issue(s)"; fi
  [ "$issues" -eq 0 ]
}
