#!/bin/bash
set -euo pipefail
SCRIPT_NAME=menu

choose() {
  if (($# < 2)); then
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
      '[A' | 'OA') selected=$(((selected + ${#options[@]} - 1) % ${#options[@]})) ;;
      '[B' | 'OB') selected=$(((selected + 1) % ${#options[@]})) ;;
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

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || fail "Required command missing: $1"; }

interactive() { [[ -t 2 ]] && ( : </dev/tty ) 2>/dev/null; }

ask() {
  interactive || return 1
  local answer
  printf '%s [y/N] ' "$1" >&2
  IFS= read -r answer </dev/tty || return 1
  [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]
}

prompt() {
  interactive || fail "Supply arguments when running without a terminal; see --help."
  printf '%s: ' "$1" >&2
  IFS= read -r REPLY </dev/tty || fail 'Input cancelled.'
  [[ -n "$REPLY" ]] || fail 'A value is required.'
}

shortcut() {
  [[ ${SIMPLYHOST_NO_SHORTCUT:-0} == 1 ]] && return 0
  local name="sh-$SCRIPT_NAME" target base line source_path staging
  ask "Add command '$name' to ~/.bashrc for repeat use?" || return 0
  base="$HOME/.local/share/simplyhost/scripts"
  target="$base/$SCRIPT_NAME.sh"
  mkdir -p "$base"
  staging=$(mktemp "$base/.install.XXXXXX")
  source_path=${BASH_SOURCE[0]:-}
  if [[ -f "$source_path" ]]; then
    cp -- "$source_path" "$staging"
  else
    need curl
    if ! curl -fsSL "https://scripts.simplyhost.org/$SCRIPT_NAME.sh" -o "$staging"; then
      rm -f -- "$staging"; fail 'Could not save the script for repeat use.'
    fi
  fi
  if ! bash -n "$staging"; then rm -f -- "$staging"; fail 'Downloaded script failed syntax validation.'; fi
  chmod 700 "$staging"
  mv -f -- "$staging" "$target"
  printf -v line '%s() { SIMPLYHOST_NO_SHORTCUT=1 bash %q "$@"; }' "$name" "$target"
  if [[ ! -f "$HOME/.bashrc" ]] || ! grep -Fqx -- "$line" "$HOME/.bashrc"; then
    printf '\n# SimplyHost: %s\n%s\n' "$name" "$line" >> "$HOME/.bashrc"
  fi
  printf 'Saved %s. Open a new Bash shell or run: source ~/.bashrc\n' "$name"
}

if [[ ${1:-} == --help ]]; then echo 'Usage: menu.sh — searchable SimplyHost script launcher'; exit 0; fi
[[ $# -eq 0 ]] || fail 'Usage: menu.sh'
interactive || fail 'The menu requires an interactive terminal.'
shortcut
names=(doctor docker new-service backup backup-check ports storage inventory health logs compose-update iterm2 nvim)
descriptions=('Host readiness report' 'Install Docker and Compose' 'Create a Compose service' 'Create a verified backup' 'Verify backups and freshness' 'Inspect listening ports' 'Inspect disks and mounts' 'Export JSON inventory' 'Host and container health' 'View service logs' 'Update a Compose project' 'Install the captured iTerm2 profile' 'Install Neovim configuration')
source_directory=''
if [[ -f ${BASH_SOURCE[0]:-} ]]; then source_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd); fi
while :; do
  prompt 'Search scripts (all to list, q to quit)'; query=$REPLY
  [[ "$query" != q ]] || exit 0
  options=(); matching=()
  for index in "${!names[@]}"; do
    case "$(uname -s):${names[$index]}" in
      Linux:iterm2|Darwin:docker) continue ;;
    esac
    entry="${names[$index]} — ${descriptions[$index]}"
    if [[ "$query" == all ]] || printf '%s\n' "$entry" | grep -Fqi -- "$query"; then
      options+=("$entry"); matching+=("${names[$index]}")
    fi
  done
  if [[ ${#options[@]} -eq 0 ]]; then echo 'No matches.'; continue; fi
  options+=('Back')
  selection=$(choose 'Run a script' "${options[@]}")
  [[ "$selection" != Back ]] || continue
  name=''
  for index in "${!matching[@]}"; do
    if [[ "$selection" == "${options[$index]}" ]]; then name=${matching[$index]}; break; fi
  done
  [[ -n "$name" ]] || fail 'Invalid selection.'
  if [[ -n "$source_directory" && -f "$source_directory/$name.sh" ]]; then
    if ! bash "$source_directory/$name.sh"; then printf '%s reported an error.\n' "$name" >&2; fi
  else
    need curl
    staging=$(mktemp -d); trap 'rm -rf -- "$staging"' EXIT
    if curl -fsSL "https://scripts.simplyhost.org/$name.sh" -o "$staging/$name.sh" && bash -n "$staging/$name.sh"; then
      # Let downloaded children install their own persistent shortcut if requested.
      if ! bash "$staging/$name.sh"; then printf '%s reported an error.\n' "$name" >&2; fi
    else printf 'Could not download %s.\n' "$name" >&2; fi
    rm -rf -- "$staging"; trap - EXIT
  fi
done
