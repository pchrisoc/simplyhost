#!/bin/bash
set -euo pipefail
SCRIPT_NAME=health

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

if [[ ${1:-} == --help ]]; then echo 'Usage: health.sh — report host and container health; exit 1 on detected problems'; exit 0; fi
[[ $# -eq 0 ]] || fail 'Usage: health.sh'
issues=0
heading 'Host'; uptime; df -h /
used=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if [[ "$used" =~ ^[0-9]+$ && $used -ge 90 ]]; then echo 'LOW SPACE: root filesystem is at least 90% full.'; issues=$((issues+1)); fi
if [[ -r /proc/meminfo ]]; then
  if awk '/MemTotal:/ {total=$2} /MemAvailable:/ {available=$2; found=1} END {exit !(found && total>0 && available/total<0.1)}' /proc/meminfo; then
    echo 'MEMORY PRESSURE: less than 10% of memory is available.'; issues=$((issues+1))
  fi
fi
if command -v free >/dev/null 2>&1; then free -h; fi
if [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1; then
  heading 'Failed system services'
  failed=$(systemctl --failed --no-legend --plain --no-pager)
  printf '%s\n' "${failed:-None}"; [[ -z "$failed" ]] || issues=$((issues+1))
fi
if command -v docker >/dev/null 2>&1; then
  heading 'Containers'
  if docker info >/dev/null 2>&1; then
    docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    ids=$(docker ps -aq)
    for id in $ids; do
      state=$(docker inspect --format '{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$id")
      case "$state" in
        'running healthy'|'running no-healthcheck'|'exited no-healthcheck')
          if [[ "$state" == 'exited no-healthcheck' && $(docker inspect --format '{{.State.ExitCode}}' "$id") != 0 ]]; then issues=$((issues+1)); fi ;;
        *) issues=$((issues+1)) ;;
      esac
    done
  else echo 'Docker daemon unavailable.'; issues=$((issues+1)); fi
fi
printf '\nDetected problems: %s (containers without health checks only report process state).\n' "$issues"
shortcut
[[ $issues -eq 0 ]]
