#!/bin/bash
set -euo pipefail
SCRIPT_NAME=ports

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

heading() { printf '\n%s\n' "$*"; }



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

if [[ ${1:-} == --help ]]; then echo 'Usage: ports.sh [PORT ...] — list TCP/UDP listeners or check port conflicts'; exit 0; fi
platform=$(uname -s)
case "$platform" in
  Linux) need ss ;;
  Darwin) need lsof ;;
  *) fail 'Use the Windows PowerShell version on Windows.' ;;
esac
if [[ $# -eq 0 ]]; then
  heading 'Listening TCP and UDP ports (process names may require root)'
  if [[ "$platform" == Linux ]]; then ss -lntup
  else
    lsof -nP -iTCP -sTCP:LISTEN || [[ $? -eq 1 ]]
    lsof -nP -iUDP || [[ $? -eq 1 ]]
  fi
else
  conflicts=0
  for port in "$@"; do
    [[ "$port" =~ ^[0-9]{1,5}$ ]] || fail "Invalid port: $port"
    port=$((10#$port)); [[ $port -ge 1 && $port -le 65535 ]] || fail "Invalid port: $port"
    if [[ "$platform" == Linux ]]; then listeners=$(ss -H -lntu "sport = :$port")
    else
      listeners=$({ lsof -nP -iTCP:"$port" -sTCP:LISTEN || [[ $? -eq 1 ]]; lsof -nP -iUDP:"$port" || [[ $? -eq 1 ]]; })
    fi
    if [[ -n "$listeners" ]]; then printf 'IN USE: %s\n%s\n' "$port" "$listeners"; conflicts=$((conflicts+1)); else printf 'AVAILABLE: %s\n' "$port"; fi
  done
fi
shortcut
[[ ${conflicts:-0} -eq 0 ]]
