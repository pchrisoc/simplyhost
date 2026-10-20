#!/bin/bash
set -euo pipefail

logo() {
  printf '\033[2J\033[H'
  echo "   _____ _                 _       "
  echo "  / ____(_)               | |      "
  echo " | (___  _ _ __ ___  _ __ | |_   _ "
  echo "  \\___ \\| | '_ \` _ \\| '_ \\| | | | |"
  echo "  ____) | | | | | | | |_) | | |_| |"
  echo " |_____/|_|_| |_| |_| .__/|_|\\__, |"
  echo "    _    _          | |       __/ |"
  echo "   | |  | |         | |      |___/ "
  echo "   | |__| | ___  ___| |_           "
  echo "   |  __  |/ _ \\/ __| __|          "
  echo "   | |  | | (_) \\__ \\ |_           "
  echo "   |_|  |_|\\___/|___/\\__|          "
  echo "                                   "
  echo "                                   "
}

# Usage: choice=$(choose "Title" "Option 1" "Option 2" ...)
choose() {
  if (( $# < 2 )); then
    printf 'Usage: choose "Title" "Option 1" ["Option 2" ...]\n' >&2
    return 2
  fi
  local title="$1"
  shift
  local options=("$@")
  local selected=0 index key sequence
  printf '%s (Up/Down, Enter)\n' "$title" >&2
  while :; do
    for index in "${!options[@]}"; do
      printf '\r\033[2K' >&2
      if [[ "$index" -eq "$selected" ]]; then
        printf '\033[7m > %s \033[0m\n' "${options[$index]}" >&2
      else
        printf '   %s\n' "${options[$index]}" >&2
      fi
    done
    IFS= read -r -s -n 1 key </dev/tty || return 1
    case "$key" in
      $'\033')
        sequence=''
        IFS= read -r -s -n 2 -t 1 sequence </dev/tty || true
        case "$sequence" in
          '[A'|'OA') selected=$(( (selected + ${#options[@]} - 1) % ${#options[@]} )) ;;
          '[B'|'OB') selected=$(( (selected + 1) % ${#options[@]} )) ;;
        esac
        ;;
      '')
        printf '%s\n' "${options[$selected]}"
        return 0
        ;;
    esac
    printf '\033[%sA' "${#options[@]}" >&2
  done
}


logo

# Example: choice=$(choose "What would you like to do?" "Install" "Quit")
