#!/usr/bin/env bash
# ui.sh — interactive selection UI with graceful degradation.
# Backends, best first: gum > whiptail > plain read-based checkbox.
# Requires common.sh sourced first.
#
# Public API:
#   menu_checkbox "Title"   — reads parallel arrays MENU_IDS/MENU_LABELS/MENU_DEFAULTS
#                             (DEFAULTS entries are "on" or "off"); sets MENU_SELECTED
#                             to a newline-separated list of chosen ids.
#
# Non-interactive (no TTY or AITO_ASSUME_YES=1): selects all defaults marked "on".

ui_backend() {
  if [ "${AITO_UI:-auto}" = "plain" ]; then echo plain; return; fi
  if have gum; then echo gum
  elif have whiptail; then echo whiptail
  else echo plain
  fi
}

_menu_default_selection() {
  # Emit ids whose default is "on", one per line.
  local i=0
  while [ "$i" -lt "${#MENU_IDS[@]}" ]; do
    [ "${MENU_DEFAULTS[$i]}" = "on" ] && printf '%s\n' "${MENU_IDS[$i]}"
    i=$((i + 1))
  done
}

_menu_gum() {
  local title="$1" i=0 args=() selected=()
  for ((i = 0; i < ${#MENU_IDS[@]}; i++)); do
    args+=("${MENU_LABELS[$i]}")
    [ "${MENU_DEFAULTS[$i]}" = "on" ] && selected+=("${MENU_LABELS[$i]}")
  done
  local sel_csv; sel_csv="$(IFS=,; echo "${selected[*]}")"
  local chosen
  chosen="$(printf '%s\n' "${args[@]}" \
    | gum choose --no-limit --header "$title" --selected="$sel_csv")" || return 1
  # Map chosen labels back to ids.
  MENU_SELECTED=""
  local line j
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    for ((j = 0; j < ${#MENU_LABELS[@]}; j++)); do
      if [ "${MENU_LABELS[$j]}" = "$line" ]; then
        MENU_SELECTED="${MENU_SELECTED}${MENU_IDS[$j]}"$'\n'
      fi
    done
  done <<EOF
$chosen
EOF
}

_menu_whiptail() {
  local title="$1" i=0 args=() chosen
  for ((i = 0; i < ${#MENU_IDS[@]}; i++)); do
    args+=("${MENU_IDS[$i]}" "${MENU_LABELS[$i]}" "${MENU_DEFAULTS[$i]}")
  done
  chosen="$(whiptail --title "$title" --checklist "Space to toggle, Enter to confirm" \
    20 78 10 "${args[@]}" 3>&1 1>&2 2>&3)" || return 1
  # whiptail returns "id1" "id2" (quoted, space separated)
  MENU_SELECTED="$(printf '%s\n' "$chosen" | tr ' ' '\n' | sed 's/"//g' | grep -v '^$')"
}

_menu_plain() {
  local title="$1" i state choice
  # Local toggle state mirrors MENU_DEFAULTS.
  local -a state_arr=()
  for ((i = 0; i < ${#MENU_IDS[@]}; i++)); do state_arr+=("${MENU_DEFAULTS[$i]}"); done

  while :; do
    printf '\n%s%s%s\n' "$C_BOLD" "$title" "$C_RESET" >&2
    for ((i = 0; i < ${#MENU_IDS[@]}; i++)); do
      if [ "${state_arr[$i]}" = "on" ]; then state="[x]"; else state="[ ]"; fi
      printf '  %2d) %s %s\n' "$((i + 1))" "$state" "${MENU_LABELS[$i]}" >&2
    done
    printf '%sToggle number(s), "a" all, "n" none, Enter to confirm:%s ' "$C_DIM" "$C_RESET" >&2
    read -r choice || choice=""
    case "$choice" in
      "") break ;;
      a|A) for ((i = 0; i < ${#state_arr[@]}; i++)); do state_arr[i]="on"; done ;;
      n|N) for ((i = 0; i < ${#state_arr[@]}; i++)); do state_arr[i]="off"; done ;;
      *)
        local tok idx
        for tok in $choice; do
          case "$tok" in
            ''|*[!0-9]*) continue ;;
          esac
          idx=$((tok - 1))
          if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#state_arr[@]}" ]; then
            if [ "${state_arr[idx]}" = "on" ]; then state_arr[idx]="off"; else state_arr[idx]="on"; fi
          fi
        done
        ;;
    esac
  done

  MENU_SELECTED=""
  for ((i = 0; i < ${#MENU_IDS[@]}; i++)); do
    [ "${state_arr[$i]}" = "on" ] && MENU_SELECTED="${MENU_SELECTED}${MENU_IDS[$i]}"$'\n'
  done
}

menu_checkbox() {
  local title="$1"
  MENU_SELECTED=""
  if [ ! -t 0 ] || [ "${AITO_ASSUME_YES:-0}" = "1" ]; then
    MENU_SELECTED="$(_menu_default_selection)"
    return 0
  fi
  case "$(ui_backend)" in
    gum)      _menu_gum "$title"      || MENU_SELECTED="$(_menu_default_selection)" ;;
    whiptail) _menu_whiptail "$title" || MENU_SELECTED="$(_menu_default_selection)" ;;
    *)        _menu_plain "$title" ;;
  esac
}

# menu_has <id> — test whether id is in MENU_SELECTED (or any newline list on stdin arg).
menu_has() {
  printf '%s\n' "$MENU_SELECTED" | grep -Fqx "$1"
}
