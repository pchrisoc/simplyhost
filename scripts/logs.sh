#!/bin/bash
set -euo pipefail
SCRIPT_NAME=logs

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

docker_ready() {
  need docker
  docker info >/dev/null 2>&1 || fail 'Docker is unavailable. Start it and check your Docker socket permissions.'
}

compose_ready() {
  docker_ready
  docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 is required.'
}

project_dir() {
  [[ -d "$1" ]] || fail "Directory does not exist: $1"
  cd -- "$1"
  [[ -f compose.yaml || -f compose.yml || -f docker-compose.yml || -f docker-compose.yaml ]] || fail 'No Compose file in this directory.'
  docker compose config --quiet
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

if [[ ${1:-} == --help ]]; then
  echo 'Usage: logs.sh [container NAME | service UNIT | compose DIRECTORY] [--follow]'
  echo 'Shows the last 100 lines; no arguments opens a menu.'; exit 0
fi
if [[ $# -eq 0 ]]; then
  interactive || fail 'Supply a log source; see --help.'
  kind=$(choose 'View logs' 'container' 'service' 'compose' 'Quit')
  [[ "$kind" != Quit ]] || exit 0
  if [[ "$kind" == container ]]; then docker_ready; docker ps -a --format '{{.Names}}'; fi
  if [[ "$kind" == service ]]; then need systemctl; systemctl list-units --type=service --all --no-pager; fi
  prompt 'Container name, systemd unit, or Compose directory'; target=$REPLY
  follow=''; if ask 'Follow new log messages?'; then follow=--follow; fi
else
  [[ $# -eq 2 || ( $# -eq 3 && $3 == --follow ) ]] || fail 'See --help for usage.'
  kind=$1; target=$2; follow=${3:-}
fi
shortcut
case "$kind" in
  container) docker_ready; docker logs --tail 100 ${follow:+--follow} -- "$target" ;;
  service) need journalctl; journalctl --no-pager -n 100 ${follow:+--follow} --unit="$target" ;;
  compose) compose_ready; project_dir "$target"; docker compose logs --tail 100 ${follow:+--follow} ;;
  *) fail 'Unknown log source. Use container, service, or compose.' ;;
esac
