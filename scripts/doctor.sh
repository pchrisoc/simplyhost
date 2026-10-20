#!/bin/bash
set -euo pipefail
SCRIPT_NAME=doctor

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

if [[ ${1:-} == --help ]]; then echo 'Usage: doctor.sh [--strict] — read-only host readiness report'; exit 0; fi
[[ $# -eq 0 || ( $# -eq 1 && $1 == --strict ) ]] || fail 'Usage: doctor.sh [--strict]'
issues=0
heading 'SimplyHost host check'
printf 'OS: %s | Architecture: %s | Host: %s\n' "$(uname -s)" "$(uname -m)" "$(hostname)"
for tool in curl tar python3 docker; do
  if command -v "$tool" >/dev/null 2>&1; then printf 'OK: %s\n' "$tool"; else printf 'MISSING: %s\n' "$tool"; issues=$((issues+1)); fi
done
heading 'Filesystem capacity'; df -h / "$HOME"
used=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if [[ "$used" =~ ^[0-9]+$ && $used -ge 90 ]]; then echo 'LOW SPACE: root filesystem is at least 90% full.'; issues=$((issues+1)); fi
if command -v free >/dev/null 2>&1; then heading 'Memory'; free -h; fi
if command -v ip >/dev/null 2>&1; then
  heading 'Addresses'; ip -brief address
  heading 'Default route'; ip route show default
  if [[ -z $(ip route show default) ]]; then echo 'No IPv4 default route found.'; issues=$((issues+1)); fi
fi
if command -v docker >/dev/null 2>&1; then
  if ! docker info >/dev/null 2>&1; then echo 'Docker daemon unavailable to this user.'; issues=$((issues+1)); fi
  if ! docker compose version; then echo 'Install Docker Compose v2.'; issues=$((issues+1)); fi
fi
if command -v pveversion >/dev/null 2>&1; then heading 'Proxmox'; pveversion; echo 'Install application runtimes inside guests.'; fi
printf '\nFindings: %s\n' "$issues"
shortcut
if [[ ${1:-} == --strict && $issues -gt 0 ]]; then exit 1; fi
